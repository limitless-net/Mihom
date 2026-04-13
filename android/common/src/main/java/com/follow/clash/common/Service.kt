package com.follow.clash.common

import android.content.Intent
import android.os.IBinder
import android.util.Log
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
            job?.cancel()
            job = null
            _serviceState.value = null
            job = launch {
                var lastError: Throwable? = null
                for (attempt in 0 until 5) {
                    if (attempt > 0) {
                        delay(1000L * attempt)
                        Log.w("ServiceDelegate", "Bind retry ${attempt + 1}/5...")
                    }
                    val result = runCatching {
                        GlobalState.application.bindServiceFlow<IBinder>(intent)
                            .collect { handleBind(it) }
                    }
                    // collect blocks forever on success, so if we reach here it failed
                    lastError = result.exceptionOrNull()
                    Log.w("ServiceDelegate", "Bind attempt ${attempt + 1}/5 failed: ${lastError?.message}")
                }
                // All attempts exhausted
                Log.e("ServiceDelegate", "All bind attempts failed: ${lastError?.message}")
                _bindingState.set(false)
            }
        }
    }

    suspend inline fun <R> useService(
        timeoutMillis: Long = 15000, crossinline block: suspend (T) -> R
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