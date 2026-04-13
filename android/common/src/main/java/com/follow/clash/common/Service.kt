package com.follow.clash.common

import android.app.ActivityManager
import android.content.Intent
import android.os.IBinder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.util.concurrent.atomic.AtomicBoolean

class ServiceDelegate<T>(
    private val intent: Intent,
    private val onServiceDisconnected: ((String) -> Unit)? = null,
    private val interfaceCreator: (IBinder) -> T,
) : CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val _bindingState = AtomicBoolean(false)

    private var _serviceState = MutableStateFlow<Pair<T?, String>?>(null)

    val serviceState: StateFlow<Pair<T?, String>?> = _serviceState
    private var job: Job? = null

    private fun handleBind(data: Pair<IBinder?, String>) {
        data.first?.let {
            _serviceState.value = Pair(interfaceCreator(it), data.second)
        } ?: run {
            _serviceState.value = Pair(null, data.second)
            unbind()
            onServiceDisconnected?.invoke(data.second)
            _bindingState.set(false)
        }
    }

    fun bind() {
        if (_bindingState.compareAndSet(false, true)) {
            startBind()
        }
    }

    fun forceBind() {
        GlobalState.log("ServiceDelegate.forceBind: cancelling old job, resetting state")
        job?.cancel()
        job = null
        _bindingState.set(false)
        _serviceState.value = null
        if (_bindingState.compareAndSet(false, true)) {
            startBind(killExisting = true)
        } else {
            GlobalState.log("ServiceDelegate.forceBind: CAS failed unexpectedly!")
        }
    }

    private fun startBind(killExisting: Boolean = false) {
        GlobalState.log("ServiceDelegate.startBind: starting, killExisting=$killExisting")
        job?.cancel()
        job = null
        _serviceState.value = null
        job = launch {
            if (killExisting) {
                try {
                    val am = GlobalState.application.getSystemService(ActivityManager::class.java)
                    val targetProcess = "${GlobalState.application.packageName}:remote"
                    val proc = am?.runningAppProcesses?.find { it.processName == targetProcess }
                    if (proc != null) {
                        GlobalState.log("ServiceDelegate.startBind: found lingering :remote process pid=${proc.pid}, killing it")
                        android.os.Process.killProcess(proc.pid)
                        delay(800L)
                        GlobalState.log("ServiceDelegate.startBind: kill delay done, proceeding to bind")
                    } else {
                        GlobalState.log("ServiceDelegate.startBind: no lingering :remote process found")
                    }
                } catch (e: Exception) {
                    GlobalState.log("ServiceDelegate.startBind: error during kill: ${e.message}")
                }
            }
            runCatching {
                GlobalState.application.bindServiceFlow<IBinder>(intent)
                    .collect {
                        GlobalState.log("ServiceDelegate: bindServiceFlow emitted: binder=${it.first != null}, msg='${it.second}'")
                        handleBind(it)
                    }
            }.onFailure {
                GlobalState.log("ServiceDelegate bind failed after all retries: ${it.message}")
                _serviceState.value = Pair(null, it.message ?: "Bind failed after all retries")
                _bindingState.set(false)
            }
        }
    }

    suspend inline fun <R> useService(
        timeoutMillis: Long = 8000, crossinline block: suspend (T) -> R
    ): Result<R> {
        return runCatching {
            withTimeout(timeoutMillis) {
                val state = serviceState.filterNotNull().first()
                state.first?.let {
                    withContext(Dispatchers.Default) {
                        block(it)
                    }
                } ?: throw Exception(state.second)
            }
        }
    }

    fun unbind() {
        if (_bindingState.compareAndSet(true, false)) {
            job?.cancel()
            job = null
            _serviceState.value = null
        }
    }
}