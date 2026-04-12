## v2.6.3

- fix: add keytool verify for keystore, reorder repos official-first aliyun-last

- fix: add assets/cer/.gitkeep, guard SERVICE_JSON secret, disable fail-fast

- fix: strip local proxy settings from gradle.properties on CI

- fix: add all plugin marker POMs to local repo + add local repo to settings

- fix: download kotlin-dsl plugin via curl from Plugin Portal

- Add Gradle init script with mirror repos for included builds

- Cache Gradle dist with actions/cache and use file:// URL to bypass services.gradle.org

- Switch to gradle-bin.zip and use setup-gradle wrapper mode for reliable CI downloads

- Track Gradle wrapper files for CI builds

- Fix gradlew path and add chmod for CI

- Add Gradle pre-download with retry logic for CI reliability

- Add Gradle setup with caching for Android builds

- chore: update SDK submodule (include generated files)

- Delete assets/config/新建 文本文档.txt

- ci: use secret for xboard config (public repo ready)

- chore: track xboard config directly (private repo)

- ci: restore xboard config from secret during build

- chore: update flutter_xboard_sdk submodule

- Cache notifier to avoid ref access in dispose

- Store the SupportChatNotifier in a late final field (_chatNotifier) during initState and use it to call init/resumePolling instead of reading the provider repeatedly. This allows dispose to call pausePolling without accessing ref (avoiding ref access during dispose). Removed the local notifier variable and updated calls accordingly.

- 1

- Add branding assets, Android config & UI modules

- Large commit adding cross-platform branding and assets, Android resource/manifest updates, and new UI modules. Introduces mihom feature pages (desktop & mobile), a ui_demo suite, and many Dart changes across lib (controllers, managers, providers, plugins). Adds xboard networking pieces (proxy-aware HTTP client), platform packaging tweaks (linux/mac/windows), pubspec/setup updates, helper scripts (env.json, fix_encoding), and build/analyze output files (analyze_output.txt). Overall this bundles asset, configuration, and feature additions plus widespread code updates/refactors.

- feat: 实现 relay:// 中继代理协议

- - 新增 relay_client.dart: HTTP POST /r 中继协议客户端

- - domain_racing_service: 域名竞速支持 relay 代理

- - subscription_downloader: 订阅下载支持 relay 代理

- - SDK http_service: Dio 拦截器实现 relay 代理

- - config_validator: 添加 relay 到有效协议列表

- - application.dart: 初始化超时处理

- - routes.dart: 加载页错误展示

- - xboard_user_provider: markInitialized()

- 0.1

- 0

- 1

- Add sqlite store

- Optimize android quick action

- Optimize backup and restore

- Optimize more details

- chore: update flutter_xboard_sdk submodule (xv2b support)

- Fix windows some issues

- Optimize overwrite handle

- Optimize access control page

- Optimize some details

- docs: update readme

- refactor: 统一代码生成输出到 generated/ 子目录

- 基于 #41 的思路，重新实现代码生成配置：

- - 更新 build.yaml，为 lib/xboard 添加代码生成规则

- - 修改 lib/xboard 下所有 part 引用路径为 generated/xxx.dart

- - 保持与 lib/models、lib/providers 一致的目录结构

- Closes #41

- Update build-guide.md

- docs: 更新文档

- feat: 根据屏幕分辨率自适应窗口大小

- - 窗口尺寸自动适配屏幕大小（最大不超过屏幕的60%）

- - 在低分辨率屏幕上自动缩小窗口，避免显示过大

- - 保持窗口固定大小，不允许用户拖动调整

- chore: 移除废弃的 DomainStatusIndicator 组件

- - 删除 lib/xboard/features/domain_status/widgets/domain_status_indicator.dart

- - 该组件已被 InitializationProvider 和 login_page.dart 中的新实现替代

- - 更新 domain_status.dart 导出文件

- 实现统一初始化服务架构

- 新增：统一初始化模块

- - 封装域名检查和SDK初始化流程

- - 提供状态管理和进度追踪

- - 幂等性保护避免重复执行

- 修复：快速认证顺序问题

- - 应用启动时后台预热初始化

- - 快速认证前等待初始化完成

- - 解决SDK未初始化报错

- 改进：登录页使用统一初始化

- - 显示初始化状态指示器

- - 登录按钮根据状态禁用

- 修复支付轮询和SDK初始化重复问题

- - 修复支付等待页面轮询逻辑：

-   * 支付状态检查立即开始（移除5秒延迟）

-   * 正确处理status==1（开通中）状态

-   * 添加应用生命周期监听，切回前台时立即检查

-   * 日志级别提升到INFO便于追踪

-   * 轮询间隔调整为3秒

- - 添加支付成功Toast通知（与登录成功一致）

- - 修复SDK初始化重复竞速问题：

-   * XBoardConfig.getFastestPanelUrl实现请求合并

-   * sdk_provider优先使用缓存的竞速结果

-   * 避免DomainStatusService和SDKProvider并发竞速

- chore: 更新 SDK 子模块引用到最新提交

- fix: 修复刷新订阅时短暂显示购买订阅的问题 #39

- - 调整导入流程顺序：先下载新配置，成功后再删除旧配置

- - 避免删除旧配置到下载完成之间的空窗期导致 UI 闪烁

- - 添加 isRefreshing 参数作为备用保护机制

- feat: 累积更新 (包含支付流程优化、SDK适配层重构)

- chore(subscription): 关闭订阅状态弹窗，改为仅依赖首页套餐卡片展示

- fix(user): 允许 planId 为空以兼容新注册用户未订阅场景

- fix(sdk): 更新 SDK 修复新用户邀请码生成和用户信息获取问题

- 更新 flutter_xboard_sdk 子模块至 d6e2899

- 修复内容：

- ----------

- 1. 生成邀请码失败

-    - 后端返回 boolean，客户端期望对象

-    - 修改为调用后重新获取邀请信息

- 2. 新用户信息解析失败

-    - 新用户字段为 null 导致类型转换失败

-    - 为可空字段添加 @Default 默认值

- 相关 Issue：

- -----------

- - 新注册用户首次进入邀请页面生成邀请码失败

- - 需要重新登录才能生成

- - 错误：type cast 异常

- fix(payment): 修复余额支付数据类型转换错误

- 问题：

- -----

- 余额支付时出现错误："支付失败: 余额支付未成功"

- 根本原因：

- ---------

- 1. 后端返回余额支付结果：{ type: -1, data: true }

- 2. Repository 层错误地将 data 转换为字符串：data.toString() → "true"

- 3. Page 层检查 paymentData == true 失败（"true" != true）

- 修复内容：

- ---------

- 1. PaymentResult 领域模型

-    - data 字段类型从 String? 改为 dynamic

-    - 添加 isBalancePaid getter（type == -1 && data == true）

-    - 添加 paymentUrl getter 用于获取支付 URL

- 2. XBoardPaymentRepository

-    - 移除 data.toString() 强制转换

-    - 保持原始类型：bool 或 String

-    - 添加调试日志显示 data 类型

- 3. PlanPurchasePage

-    - 添加调试日志显示支付数据实际类型

-    - 优化错误提示信息

- 影响：

- -----

- ✅ 余额支付现在可以正常工作

- ✅ 第三方支付（跳转/二维码）不受影响

- ✅ 类型安全性提升

- fix(auth): 修复注册页面配置和错误提示

- 1. 注册错误提示优化

-    - 识别 500 错误，提示可能是邀请码不正确

-    - 添加 inviteCodeIncorrect 国际化翻译（中英日俄）

- 2. 配置自动刷新

-    - configProvider 改为 FutureProvider.autoDispose

-    - 每次进入注册页面都重新获取最新配置

-    - 确保邮箱验证、邀请码等配置实时生效

- 3. 国际化更新

-    - arb: 添加 inviteCodeIncorrect 源翻译

-    - l10n: 同步生成多语言支持

- 4. 配置文档更新

-    - 标注 v2board 正在建设中

- 依赖更新：

- - 更新 flutter_xboard_sdk submodule（仅 XBoard API 修复）

- 影响：

- - ✅ 注册失败提示更友好明确

- - ✅ 配置修改后立即生效，无需重启

- - ✅ 多语言支持完善

- refactor: 完成 Clean Architecture 重构并修复订单自动取消逻辑

- 主要改动：

- 1. 架构优化

-    - 删除所有兼容性 typedef 类型别名（~15个）

-    - UI层完全使用 Domain Models（DomainPaymentMethod等）

-    - 移除 Domain → SDK 的类型转换代码

-    - 统一使用 Repository 接口进行数据访问

- 2. 订单自动取消逻辑修复

-    - 修复过滤条件：同时取消 pending(0) 和 processing(1) 订单

-    - 更新 OrderStatus.canCancel 逻辑

-    - 添加 shouldAutoCancelBeforeNewOrder 业务方法

-    - 修复「未付款或开通中的订单」创建失败问题

- 3. Repository 模式完成

-    - AuthRepository: forgot_password, register

-    - PaymentRepository: plan_purchase

-    - OrderRepository: payment_gateway, payment_waiting

-    - SubscriptionRepository: subscription_page

-    - 保留特殊服务直接使用 SDK（性能关键）

- 4. 类型系统改进

-    - SDK 方法返回实际类型（sdk.PaymentMethodInfo）

-    - StorageService 使用明确的 SDK 类型

-    - 支付方式选择器直接使用 DomainPaymentMethod

- 编译状态：0 errors ✅

- refactor(xboard): 完成 Clean Architecture 重构和 Bug 修复

- 主要改动：

- 1. 实现 Clean Architecture 分层

-    - 添加 domain 层：models、repositories 接口

-    - 添加 infrastructure 层：repository 实现

-    - UI 层通过 repository 接口访问数据

- 2. 修复佣金相关 Bug

-    - 修复佣金比例显示错误（50% 显示为 0.5%）

-    - 修复可划转/提现金额重复除以100的问题

-    - 提现方式改为下拉选择

- 3. 修复导航崩溃

-    - Token 过期后使用 go_router 声明式导航

-    - 避免命令式 API 与 page-based 路由冲突

- 4. 修复登录流程

-    - 登录成功后自动导入订阅配置

-    - 添加配置导入日志输出

- 5. 移除假数据

-    - 清理 domain models 中 SDK 不存在的字段

-    - 确保数据映射的准确性

- docs: update quick-start guide with minimal configuration and multi-site tips

- chore: 更新配置管理与安全策略

- 1. 配置文件调整：

-    - 移除 xboard.config.example.yaml 中不再使用的 domain_service 和 certificate 配置

-    - 将 decrypt_key 移动到 subscription 配置块下

-    - 添加 remote.config.example.json 示例文件

- 2. 代码逻辑更新：

-    - config_file_loader.dart: 移除废弃的 domain_service 读取逻辑

-    - config_file_loader.dart: 硬编码证书路径为 assets/cer/client-cert.crt，不再从配置文件读取

-    - main.dart: 移除未使用的配置读取代码

- 3. 版本控制：

-    - .gitignore: 忽略 assets/cer/ 目录下的证书文件，防止敏感信息泄露

- feat: 集成 XBoard 功能模块与架构优化

- 核心功能：

- - 订阅管理：实现订阅下载、状态检查、自动导入流程

- - 支付系统：集成支付网关、套餐购买、订单管理

- - 域名竞速：实现多域名/代理自动竞速选择最优节点

- - 邀请系统：佣金提现、划转、邀请码管理

- 架构优化：

- - SDK重构：升级 flutter_xboard_sdk 支持策略模式和多面板

- - 状态管理：优化订阅状态检查逻辑，移除轮询，使用事件驱动

- - 异常处理：统一错误提示和日志格式

- - 配置管理：优化配置加载流程，支持动态 HTTP 配置

- 修复与改进：

- - 修复订阅状态检查误报无订阅的问题

- - 修复支付返回类型兼容性问题 (bool/String)

- - 优化 UI 交互，统一通知组件风格

- - 移除冗余的 API 调用和重复导入逻辑

- docs: 完善配置文件操作说明并统一配置源命名

- docs: 添加脱敏的配置文件示例

- docs: 添加 Telegram 群组链接并更新问题反馈方式

- docs: 修复图片符号链接并优化截图展示为单行布局

- docs: 在 README 顶部添加 MotionPay 广告位

- docs: 在 README 中添加应用截图展示

- 优化：简化登录按钮样式，使用标准 FilledButton

- 清理：移除无效的路由配置和调试日志

- 修复：恢复使用 MaterialPageRoute 直接导航到注册和忘记密码页面

- 修复：适配新路由系统，修复登录、注册、忘记密码页面导航

- 优化：简化邀请页面英文翻译，避免文本换行

- 修复：移除未使用的validInvites getter

- 修复：钱包卡片显示可用佣金、待处理佣金、钱包余额

- 修复：邀请页面统计卡片显示返利比例，修正stat数组索引定义

- 修复：恢复邀请页面返利比例显示

- 优化支付流程：实付金额为0时自动选择第一个支付方式完成余额支付

- feat: 优化订阅过期提醒和续费功能

- 主要改进：

- - 优化过期提醒弹窗的按钮布局（竖排、宽度一致、右对齐）

- - 在主页套餐卡片中添加续费按钮

- - 续费按钮智能跳转：移动端直接跳转到当前套餐购买页面，桌面端内嵌显示购买界面

- - Plans页面支持URL参数planId，实现桌面端自动选中套餐

- - 确保套餐列表加载后再跳转，提升用户体验

- 影响文件：

- - subscription_status_dialog.dart: 优化按钮布局

- - subscription_usage_card.dart: 添加续费按钮

- - subscription_status_checker.dart: 智能续费跳转逻辑

- - plans.dart: 支持URL参数自动选中套餐

- - subscription_status_service.dart: 关闭调试模式

- refactor: 统一平台判断逻辑并优化UI布局

- - 修复续费按钮导航问题：移动端使用push保留路由栈，桌面端使用go切换分支

- - 将所有平台判断从屏幕宽度(>600)改为Platform检测(isLinux/isWindows/isMacOS)

- - 移除UI组件中不必要的isDesktop判断，统一使用固定值实现相对布局

- - 修复桌面端侧边栏在浅色模式下使用渐变色的问题，改为纯色背景

- - 关闭订阅状态服务的调试模式(debugForceExpired)

- 影响文件：

- - 导航和路由：shell_layout.dart, subscription_status_checker.dart

- - 页面组件：xboard_home_page.dart, invite_page.dart, online_support_page.dart

- - 支付相关：plan_purchase_page.dart及相关widgets

- - 侧边栏：desktop_navigation_rail.dart

- refactor: 简化订阅信息获取，只使用响应头方式

- - 移除通过 XBoard API 获取订阅信息的方式

- - 直接从订阅链接响应头 subscription-userinfo 解析信息

- - 与 fl_clash 原始实现保持一致

- - 减少不必要的 API 调用，提高性能

- refactor: 导航栏使用国际化替换硬编码文本

- - 移动端底部导航栏：使用 appLocalizations.xboardHome 和 appLocalizations.invite

- - 桌面端侧边导航栏：使用 appLocalizations.xboardHome, appLocalizations.xboardPlans, appLocalizations.onlineSupport, appLocalizations.invite

- - 移除硬编码的中文文本，支持多语言切换

- - 使用项目统一的 appLocalizations 命名规范

- fix: 修复桌面端和移动端导航问题

- - 桌面端：侧边栏使用 context.go() 在 Shell 内切换页面

- - 移动端：首页按钮使用 context.push() 创建路由栈以便返回

- - Plans 和 Support 页面：移动端使用 PopScope 拦截返回按钮导航回首页

- - 桌面端：Plans 和 Support 页面不显示 AppBar，由 Shell 提供导航

- - 修复：将 Plans 和 Support 页面重新加入 StatefulShellRoute，保持桌面端侧边栏显示

- feat: 优化支付页面UI和交互体验

- - 价格汇总：实付金额显示余额抵扣信息，余额抵扣和剩余余额在同一行显示

- - 周期选择器：实现自适应全屏布局，根据屏幕大小动态调整间距、字体、图标等尺寸

- - 周期卡片：内容居中对齐，紧凑显示，优化视觉效果

- - 订单确认页面：内容从顶部开始排列，充分利用屏幕空间

- - 套餐信息卡片：正确显示无限制的流量和网速，支持国际化

- - 优惠券输入：点击验证按钮后自动收起键盘，优化输入文字样式

- - 修复：将废弃的 withOpacity() 改为 withValues(alpha:)

- feat: 优化导航和页面状态管理

- 主要改进：

- 1. 路由架构优化

-    - 将套餐和客服页面从 StatefulShellRoute 移至独立全屏路由

-    - 使用 push 而非 go，正确管理路由栈和返回行为

-    - 手机端套餐和客服页面全屏显示，无底部导航栏

- 2. 页面状态保持

-    - 首页添加 AutomaticKeepAliveClientMixin 防止重建

-    - 邀请页添加 AutomaticKeepAliveClientMixin 防止重建

-    - 避免切换页面时重复请求 API

- 3. UI优化

-    - 缩小底部导航栏高度（80→60）

-    - 修复通知对话框关闭时键盘弹出问题

-    - 套餐页面自动显示返回按钮

- 4. 导航体验改进

-    - 套餐/客服页面按返回键正确返回首页

-    - 移除不必要的手动返回键拦截

-    - 完全由 Flutter 路由系统管理导航

- feat: 优化导航和国际化

- - 简化英文翻译：'Online Support' -> 'Support', 'Plan Information' -> 'Plans'

- - 将 ShellRoute 改为 StatefulShellRoute.indexedStack 以保持页面状态

- - 修复移动端底部导航栏无法直接跳转邀请页面的问题

- - 优化页面切换，避免重复请求 API 和重建组件

- - 删除已废弃的 UA_VERIFICATION.md 文件

- refactor: 调整客服按钮布局，移动端从底部导航移到首页

- 移动端：

- - ✅ 首页左上角显示客服按钮（图标+文字）

- - ❌ 移除底部导航栏的客服入口

- - 📱 底部导航栏简化为：首页、套餐、邀请（3个）

- 桌面端：

- - ✅ 保持侧边导航栏的客服按钮

- - 📋 侧边栏完整导航：首页、套餐、客服、邀请（4个）

- 技术实现：

- - MobileNavigationBar: 移除客服项，简化为StatelessWidget

- - AdaptiveShellLayout: 分别处理桌面端和移动端的索引映射

- - DesktopNavigationRail: 保持不变

- 用户体验：

- - 移动端：客服按钮更显眼（首页顶部）

- - 桌面端：保持完整的侧边导航

- - 统一：两端都能快速访问客服功能

- feat: 客服按钮添加国际化文字标签

- 改进：

- - 将 IconButton 改为 TextButton.icon

- - 添加 onlineSupport 国际化文字标签

- - 调整 leadingWidth 为 120 以容纳文字

- - 与右侧套餐按钮保持样式一致

- 支持语言：

- - 中文：在线客服

- - 英文：Online Support

- - 日文：オンラインサポート

- - 俄文：Онлайн поддержка

- refactor: 移除手机端首页AppBar标题，保持简洁

- 修改：

- - 去掉 AppBar 的 title 属性

- - 保留左侧客服按钮和右侧套餐信息按钮

- - 更简洁的顶部栏设计

- feat: 在手机端首页左上角添加在线客服按钮

- 添加位置：

- - 手机端首页 AppBar 的 leading 位置（左上角）

- - 仅在手机端显示（桌面端保持在导航栏）

- 图标：

- - 使用 support_agent 图标

- - 点击跳转到 /support 在线客服页面

- 用户体验：

- - 方便手机用户快速访问客服

- - 与右上角的套餐信息按钮保持平衡

- refactor: 删除已废弃的 ModuleLogger 系统

- 删除文件：

- - module_loggers.dart (226行)

-   包含: ProfileLogger, AuthLogger, FeatureLogger, ConfigLogger,

-        ServiceLogger, DomainServiceLogger, SharedLogger,

-        NetworkLogger, SystemLogger

- 原因：

- - 所有代码已完全迁移到 FileLogger

- - 旧的模块分类日志系统已不再使用

- - 简化代码库，保持单一日志实现

- 当前日志系统：

- ✅ FileLogger - 文件级日志，初始化一次，自动带文件名标签

- ✅ ConsoleLogger - 底层实现，统一格式输出

- ✅ LoggerInterface - 接口定义，支持自定义实现

- fix: 修复ConsoleLogger日志格式不一致问题

- 问题：

- - 主日志消息包含时间戳: [XBoard][03:30:23][ERROR] ...

- - 错误详情缺少时间戳: [XBoard][ERROR] Error: ...

- - 堆栈跟踪也缺少时间戳

- 修复：

- - 统一所有日志输出格式，包括错误详情和堆栈跟踪

- - 现在所有日志行都包含: [XBoard][时间][级别] ...

- - 修复 xboard_sdk.dart 中 FileLogger 初始化位置（移到export后）

- 修复后效果：

- [XBoard][03:30:23][ERROR] [update_check_provider.dart] 检查更新失败

- [XBoard][03:30:23][ERROR] Error: DioException...

- [XBoard][03:30:23][ERROR] StackTrace: ...

- refactor: 整个xboard模块完全迁移到FileLogger日志系统

- 批量替换以下模块的日志系统：

- - features/online_support (8个文件)

- - features/payment (3个文件)

- - features/shared (1个文件)

- - features/subscription (2个文件)

- - features/update_check (1个文件)

- - features/domain_status (2个文件)

- - features/remote_task (2个文件)

- - config/utils (1个文件)

- - infrastructure/http (1个文件)

- 所有旧Logger已替换为FileLogger：

- ❌ XBoardLogger, DomainServiceLogger, ServiceLogger, NetworkLogger, ConfigLogger

- ✅ FileLogger (每个文件初始化一次)

- 日志格式统一为: [文件名.dart] 消息内容

- refactor: 替换sdk和infrastructure模块为FileLogger

- - xboard_sdk.dart: 替换 XBoardLogger → FileLogger

- - xboard_client.dart: 替换 XBoardLogger → FileLogger

- - domain_racing_service.dart: 替换 XBoardLogger → FileLogger

- - xboard_http_client.dart: 添加 FileLogger 初始化

- - 修复日志标签：[SDK]、[域名竞速] → [文件名.dart]

- fix: 修复xboard_config_accessor.dart的import顺序错误

- - 将FileLogger初始化移到所有import语句之后

- - Dart要求所有import必须在声明之前

- refactor: 整个xboard模块替换为FileLogger日志系统

- - error_handler.dart: 替换 NetworkLogger/ConfigLogger/XBoardLogger

- - xboard_config_accessor.dart: 替换 ConfigLogger

- - remote_config_manager.dart: 替换 NetworkLogger

- - module_initializer.dart: 替换 ConfigLogger/ServiceLogger

- - 所有文件使用统一的 FileLogger 初始化方式

- - xboard模块不再使用旧的模块Logger

- refactor: 重构日志系统为文件级日志器

- - 新增 FileLogger 类，支持文件顶部初始化一次

- - 使用方式：final _logger = FileLogger('文件名.dart');

- - 调用时无需传递文件名，自动添加文件标签

- - 更新 auto_latency_service.dart 使用新日志系统

- - 更新 update_check_provider.dart 使用新日志系统

- - 更新 profile_import_service.dart 使用新日志系统

- - 简化日志调用：_logger.info('消息') 而不是传递多个参数

- feat: 为日志系统添加文件名标签支持

- - 修复所有模块Logger(ProfileLogger/AuthLogger/FeatureLogger等)使用fileName参数

- - 格式: [文件名][模块] 消息 (如果提供了fileName)

- - 更新update_check_provider.dart使用FeatureLogger并传递文件名

- - 更新auto_latency_service.dart使用FeatureLogger并传递文件名

- - 示例: [update_check_provider.dart][Feature] 当前版本: 2.6.1

- fix: 修复新路由系统下订阅导入后节点不显示的问题

- - 修复 _applyProfile() 直接调用 _setupClashConfig() 而不是 setupClashConfig()

- - 原因：go_router 下 homeScaffoldKey 失效，setupClashConfig() 检查 mounted 失败

- - 在 profile_import_service 中使用 silence 模式应用配置

- - 添加用户菜单到桌面端导航栏底部

- 重构: 优化导航栏代码结构

- - 将导航栏组件从 router 文件夹提取到独立的 widgets/navigation

- - 创建 DesktopNavigationRail 和 MobileNavigationBar 组件

- - 移除侧边栏顶部品牌区域，保持简洁

- - shell_layout.dart 从 293 行减至 82 行

- - 优化桌面端购买页面导航，添加标准返回按钮

- - 移动端使用 Navigator.push 实现原生导航体验

- 优化: 桌面端套餐购买页面内嵌显示

- - PlansView 支持状态管理，桌面端内嵌显示购买页面

- - 移动端保持全屏导航模式

- - 修复 Material 上下文错误，避免嵌套 Scaffold

- - 添加返回套餐列表功能

- - 桌面端保持侧边栏可见

- 重构: 完全替换为 go_router 路由系统

- - 创建新的 xboard/router 目录结构

- - 实现 AdaptiveShellLayout 支持桌面/移动端适配

- - 添加 ValueKey 确保页面正确切换

- - 移除 PageMixin 依赖，使用标准 Scaffold

- - 支持 11 个路由（Shell 内 4 个，独立 7 个）

- - 集成认证重定向逻辑

- - 响应式导航栏（桌面侧边栏，移动底部栏）

- 重构并优化 payment 模块

- ✨ 功能改进

- - 修复优惠券切换周期后价格不重新计算的 bug

- - 优化桌面端显示效果，限制内容最大宽度 600px

- - 桌面端使用 Scaffold 而非 CommonScaffold，保留侧边栏

- 🎨 UI 优化

- - 套餐卡片改为简约蓝色背景，去除渐变

- - 套餐信息两行布局：名称+详情居中

- - 周期选择器更紧凑，桌面端 3 列网格

- - 价格汇总卡片展示更清晰

- 🏗️ 代码重构

- - 主文件从 1217 行缩减至 620 行 (减少 50%)

- - 拆分出独立组件：

-   * plan_header_card.dart - 套餐信息卡片

-   * period_selector.dart - 周期选择器

-   * coupon_input_section.dart - 优惠券输入

-   * price_summary_card.dart - 价格汇总

-   * price_calculator.dart - 价格计算工具类

- - 代码更易维护、测试和复用

- 更新 flutter_xboard_sdk 子模块

- - 修复工单API类型处理问题

- 修复优惠券核销后显示null的问题

- - 修改 XBoardSDK.checkCoupon 返回完整优惠券数据

- - 根据优惠券类型（金额/百分比）正确计算折扣金额

- - 增加 null 检查避免显示 null 文本

- fix: 修复订阅计划不显示问题

- - 将 Plan 模型的 sort 字段改为可空类型(int?)，允许后端返回 null 值

- - 在订阅提供者中添加按 sort 字段排序逻辑

- - 确保订阅计划按正确顺序显示，null 值排在最后

- feat: 修改 prefer_encrypt 默认值为 false

- - 将订阅配置中 prefer_encrypt 的默认值从 true 改为 false

- - 默认使用普通订阅，不启用竞速功能

- - 影响文件: config_settings.dart, config_file_loader.dart

- feat: 适配黑夜模式 - 优化UI组件颜色对比度

- - 套餐描述组件：使用主题色适配背景和文字颜色

- - Proxy Mode按钮：Rule/Global/TUN模式选中时使用主题色

- - Start Proxy按钮：黑夜模式下使用浅色背景配深色文字

-   - 启动状态：浅绿色背景 + 黑色文字

-   - 未启动状态：浅蓝色背景 + 黑色文字

- - 提升所有按钮在黑夜模式下的可读性和对比度

- refactor: 套餐描述改用Markdown渲染

- 改动：

- - 移除HTML解析逻辑（parse库）

- - 改用 MarkdownBody 组件渲染

- - 移除手动文本提取和布局代码

- - 保持相同的样式（居中对齐、灰色背景）

- 优势：

- - 支持Markdown格式（标题、列表、粗体等）

- - 代码更简洁（从32行减少到20行）

- - 与通知系统渲染方式一致

- chore: 重新生成国际化代码

- - 生成 xboardUnlimited 翻译键对应的 getter

- - 修复速度限制判断逻辑（移除 == 0 判断）

- fix: 为套餐速度限制添加单位显示

- 修复内容：

- - 速度限制现在显示为 '200 Mbps' 而不是 '200'

- - 当 speedLimit 为 null 或 0 时显示 '不限速'/'Unlimited'

- - _getSpeedLimitText 返回类型从 int? 改为 String

- 翻译更新：

- - 添加 xboardUnlimited 翻译键到所有语言

- - 中文: 不限速

- - 英文: Unlimited

- - 俄文: Неограниченно

- - 日文: 無制限

- 字段说明：

- - transferEnable: double, 流量(GB)

- - speedLimit: int?, 速度限制(Mbps)，null表示不限速

- chore: 更新SDK子模块 - 清理未使用的getter方法

- SDK更新内容：

- - 移除未使用的业务逻辑方法

- - 保留核心的isVisible和hasPrice

- - 字段定义完整保留

- chore: 更新SDK子模块引用

- 更新到最新版本，包含完善的Plan模型字段定义

- refactor: 移除主页通知横幅的关闭按钮

- - 移除右侧关闭按钮，简化UI

- - 添加右侧间距保持视觉平衡

- - 用户仍可点击横幅查看完整通知

- refactor: 优化主页通知横幅设计

- - 移除渐变背景，使用纯色背景

- - 根据主题自动选择合适的surface颜色

- - 添加轻微阴影增强层次感

- - 更新图标为 campaign_rounded（更圆润）

- - 图标尺寸从16增至18

- - 文字颜色调整为 onSurface（更好适配背景）

- - 微调边框透明度和阴影参数

- feat: 添加HTML渲染支持，支持Markdown和HTML双渲染器

- - 新增 flutter_widget_from_html 依赖支持HTML渲染

- - 创建 html_styles.dart 配置HTML样式（与Markdown风格一致）

- - 实现自动检测机制：自动识别HTML或Markdown格式

- - 支持标准CSS样式（text-align等）实现居中对齐

- - 保持Markdown渲染器不变，两者可共存

- - 所有样式自动适配亮色/暗色主题

- feat: 优化通知弹窗显示效果

- - 简化弹窗布局，取消渐变效果，采用简洁设计

- - 通知标题移至顶部，自动缩放确保单行显示

- - 移除Tag显示，优化时间和内容布局

- - 创建独立的Markdown样式配置文件 (markdown_styles.dart)

- - 实现Markdown标题层级降级处理 (H1-H6)

- - 添加超链接点击支持，使用url_launcher打开外部链接

- - 增强暗色主题下的弹窗视觉区分度（背景色、边框、阴影）

- - 优化滚动和翻页交互体验

- fix: 优化支付处理和修复暗黑主题下图标颜色问题

- - 优化余额支付处理，根据后端返回的type字段判断支付类型

- - 修复邀请页面在暗黑主题下图标和文字颜色问题

- - 修复邀请统计和钱包详情图标在深色主题下颜色不明显的问题

- chore: 从版本控制中移除配置文件，防止敏感信息泄露

- feat: 添加支付方式选择功能和优化余额支付处理

- 问题描述：

- - 套餐购买时没有支付方式选择项，只会调用第一个支付方式

- - 使用余额支付时显示'无法打开支付链接'

- 修复内容：

- 1. 新增支付方式选择对话框

-    - 只有一个支付方式时自动选择

-    - 多个支付方式时弹出选择对话框

-    - 显示支付方式名称、图标和手续费

- 2. 优化余额支付处理逻辑

-    - 检测无支付链接的情况（余额支付直接扣款）

-    - 延迟检查订单状态确认支付成功

-    - 自动刷新用户订阅信息

- 3. 添加本地化支持

-    - 中文：选择支付方式、手续费

-    - 英文：Select payment method, Handling fee

- 修复后效果：

- - 多个支付方式时可以选择

- - 余额支付正常处理，不再显示错误

- - 支付成功后自动刷新订阅信息

- chore: 将本地配置文件加入 .gitignore

- fix: 修复注册时邀请码必填问题

- 问题描述：

- - Android/Windows客户端在注册时提示必须输入邀请码，但XBoard后台没有开启强制邀请码设置

- 修复内容：

- 1. register_page.dart

-    - 移除硬编码的邀请码必填检查

-    - 根据后端 isInviteForce 配置动态判断是否需要邀请码

-    - 优化邀请码标签显示：强制时显示 '邀请码 *'，可选时显示 '邀请码（可选）'

-    - 改进错误信息提取和显示逻辑，添加调试日志

- 2. xboard_sdk.dart

-    - 修复注册失败时错误信息丢失的问题

-    - 使用 rethrow 重新抛出异常，保留详细错误信息

- 3. flutter_xboard_sdk (子模块更新)

-    - 改进错误响应处理和提取逻辑

- 修复后效果：

- - 后台未开启强制邀请码时，可以不填邀请码注册

- - 邀请码字段清楚标注'（可选）'或' *'

- - 注册失败时显示后端返回的具体错误信息

- Update quick-start.md

- docs: 添加打赏支持信息

- 移除主 README 中的配置示例，引导用户查看详细文档

- Remove provider validation restrictions and update documentation

- - Remove hardcoded provider validation in config_settings and config_validator

- - Allow any provider name as long as it exists in remote config JSON

- - Add onlineSupport as required field in minimal configuration examples

- - Update quick-start guide with onlineSupport configuration details

- 重构文档结构：简化主 README，分离详细文档

- 主 README.md 变更：

- - 从 895 行精简到 230 行（-74%）

- - 保留项目简介、核心特性概述、快速开始

- - 添加清晰的文档导航

- - 移除详细配置说明和部署指南

- 新增详细文档：

- - docs/features.md (300行) - 核心特性详解

- - docs/server-deployment.md (402行) - 服务端部署指南

- 更新文档：

- - docs/README.md - 添加新文档链接

- - 更新文档导航和配置场景表格

- 文档分工：

- - 主 README：项目概览和快速导航

- - docs 目录：详细的功能、配置、部署说明

- 进一步精简构建指南文档

- - 移除平台特定工具的详细列表

- - 移除 flutter run 的参数说明和热重载说明

- - 移除常见问题部分

- - 从 297 行精简到 227 行

- - 保留最核心的构建流程和命令

- 精简构建指南文档

- - 移除详细的安装步骤说明

- - 只保留必要的工具列表和下载链接

- - 简化常见问题部分

- - 从 581 行精简到 297 行

- - 更加简洁直接，便于快速查阅

- 添加完整的构建指南文档

- - 新增 docs/build-guide.md 构建环境配置指南

- - 包含环境要求、平台特定配置、构建步骤等完整说明

- - 特别强调更新子模块后需要在 SDK 目录执行 dart build_runner

- - 添加常见问题和解决方案

- - 支持 Android、Windows、macOS、Linux 多平台构建

- - 参考 FlClash 官方构建文档编写

- 文档：明确配置模块支持不完全字段的容错机制

- 添加最小可用性配置教程和文档

- - 添加快速开始教程(docs/quick-start.md)

- - 添加文档导航页面(docs/README.md)

- - 添加最小配置示例(docs/examples/minimal.md)

- - 添加生产环境配置示例(docs/examples/production.md)

- - 重点说明主源配置模式，只需配置一个面板地址即可使用

- 更新 README 并清理文档

- 添加脱敏配置文件 config.json

- feat: 基于 FlClash 的二次开发版本

- - 完整集成 XBoard 功能模块

- - 实现域名竞速和订阅管理

- - 优化配置管理系统

- - 新增在线客服支持

- - 其他功能优化和改进

- Fix android tile service

- Support append system DNS

- Fix some issues

- Fix some issues

- Optimize Windows service mode

- Update core

- Add android separates the core process

- Support core status check and force restart

- Optimize proxies page and access page

- Update flutter and pub dependencies

- Update go version

- Optimize more details

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- cache

- Optimize desktop view

- Optimize logs, requests, connection pages

- Optimize windows tray auto hide

- Optimize some details

- Update core

- Fix windows tun issues

- Optimize android get system dns

- Optimize more details

- Support override script

- Support proxies search

- Support svg display

- Optimize config persistence

- Add some scenes auto close connections

- Update core

- Optimize more details

- Fix issues that TUN repeat failed to open.

- Fix windows service verify issues

- Add windows server mode start process verify

- Add linux deb dependencies

- Add backup recovery strategy select

- Support custom text scaling

- Optimize the display of different text scale

- Optimize windows setup experience

- Optimize startTun performance

- Optimize android tv experience

- Optimize default option

- Optimize computed text size

- Optimize hyperOS freeform window

- Add developer mode

- Update core

- Optimize more details

- Add issues template

- Optimize android vpn performance

- Add custom primary color and color scheme

- Add linux nad windows arm release

- Optimize requests and logs page

- Fix map input page delete issues

- Add rule override

- Update core

- Optimize more details

- Optimize dashboard performance

- Fix some issues

- Fix unselected proxy group delay issues

- Fix asn url issues

- Fix tab delay view issues

- Fix tray action issues

- Fix get profile redirect client ua issues

- Fix proxy card delay view issues

- Add Russian, Japanese adaptation

- Fix some issues

- Fix list form input view issues

- Fix traffic view issues

- Optimize performance

- Update core

- Optimize core stability

- Fix linux tun authority check error

- Fix some issues

- Fix scroll physics error

- Add windows storage corruption detection

- Fix core crash caused by windows resource manager restart

- Optimize logs, requests, access to pages

- Fix macos bypass domain issues

- Fix some issues

- Update popup menu

- Add file editor

- Fix android service issues

- Optimize desktop background performance

- Optimize android main process performance

- Optimize delay test

- Optimize vpn protect

- Update core

- Fix some issues

- Remake dashboard

- Optimize theme

- Optimize more details

- Update flutter version

- Support better window position memory

- Add windows arm64 and linux arm64 build script

- Optimize some details

- Remake desktop

- Optimize change proxy

- Optimize network check

- Fix fallback issues

- Optimize lots of details

- Update change.yaml

- Fix android tile issues

- Fix windows tray issues

- Support setting bypassDomain

- Update flutter version

- Fix android service issues

- Fix macos dock exit button issues

- Add route address setting

- Optimize provider view

- Update CHANGELOG.md

- Add android shortcuts

- Fix init params issues

- Fix dynamic color issues

- Optimize navigator animate

- Optimize window init

- Optimize fab

- Optimize save

- Fix the collapse issues

- Add fontFamily options

- Update core version

- Update flutter version

- Optimize ip check

- Optimize url-test

- Update release message

- Init auto gen changelog

- Fix windows tray issues

- Fix urltest issues

- Add auto changelog

- Fix windows admin auto launch issues

- Add android vpn options

- Support proxies icon configuration

- Optimize android immersion display

- Fix some issues

- Optimize ip detection

- Support android vpn ipv6 inbound switch

- Support log export

- Optimize more details

- Fix android system dns issues

- Optimize dns default option

- Fix some issues

- Update readme

- Fix build error2

- Fix build error

- Support desktop hotkey

- Support android ipv6 inbound

- Support android system dns

- fix some bugs

- Fix delete profile error

- Fix submit error 2

- Fix submit error

- Optimize DNS strategy

- Fix the problem that the tray is not displayed in some cases

- Optimize tray

- Update core

- Fix some error

- Fix tun update issues

- Add DNS override

- Fixed some bugs

- Optimize more detail

- Add Hosts override

- fix android tip error

- fix windows auto launch error

- Fix windows tray issues

- Optimize windows logic

- Optimize app logic

- Support windows administrator auto launch

- Support android close vpn

- Change flutter version

- Support profiles sort

- Support windows country flags display

- Optimize proxies page and profiles page columns

- Update flutter version

- Update version

- Update timeout time

- Update access control page

- Fix bug

- Optimize provider page

- Optimize delay test

- Support local backup and recovery

- Fix android tile service issues

- Fix linux core build error

- Add proxy-only traffic statistics

- Update core

- Optimize more details

- Add fdroid-repo

- Optimize proxies page

- Fix ua issues

- Optimize more details

- Fix windows build error

- Update app icon

- Fix desktop backup error

- Optimize request ua

- Change android icon

- Optimize dashboard

- Remove request validate certificate

- Sync core

- Fix windows error

- Fix setup.dart error

- Fix android system proxy not effective

- Add macos arm64

- Optimize proxies page

- Support mouse drag scroll

- Adjust desktop ui

- Revert "Fix android vpn issues"

- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

- Fix android vpn issues

- Fix android vpn issues

- Rollback partial modification

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external

- Override default socksPort,port

- Fix fab issues

- Update version

- Fix the problem that vpn cannot be started in some cases

- Fix the problem that geodata url does not take effect

- Update ua

- Fix change outbound mode without check ip issues

- Separate android ui and vpn

- Fix url validate issues 2

- Add android hidden from the recent task

- Add geoip file

- Support modify geoData URL

- Fix url validate issues

- Fix check ip performance problem

- Optimize resources page

- Add ua selector

- Support modify test url

- Optimize android proxy

- Fix the error that async proxy provider could not selected the proxy

- Fix android proxy error

- Fix submit error

- Add windows tun

- Optimize android proxy

- Optimize change profile

- Update application ua

- Optimize delay test

- Fix android repeated request notification issues

- Fix memory overflow issues

- Optimize proxies expansion panel 2

- Fix android scan qrcode error

- Optimize proxies expansion panel

- Fix text error

- Optimize proxy

- Optimize delayed sorting performance

- Add expansion panel proxies page

- Support to adjust the proxy card size

- Support to adjust proxies columns number

- Fix autoRun show issues

- Fix Android 10 issues

- Optimize ip show

- Add intranet IP display

- Add connections page

- Add search in connections, requests

- Add keyword search in connections, requests, logs

- Add basic viewing editing capabilities

- Optimize update profile

- Update version

- Fix the problem of excessive memory usage in traffic usage.

- Add lightBlue theme color

- Fix start unable to update profile issues

- Fix flashback caused by process

- Add build version

- Optimize quick start

- Update system default option

- Update build.yml

- Fix android vpn close issues

- Add requests page

- Fix checkUpdate dark mode style error

- Fix quickStart error open app

- Add memory proxies tab index

- Support hidden group

- Optimize logs

- Fix externalController hot load error

- Add tcp concurrent switch

- Add system proxy switch

- Add geodata loader switch

- Add external controller switch

- Add auto gc on trim memory

- Fix android notification error

- Fix ipv6 error

- Fix android udp direct error

- Add ipv6 switch

- Add access all selected button

- Remove android low version splash

- Update version

- Add allowBypass

- Fix Android only pick .text file issues

- Fix search issues

- Fix LoadBalance, Relay load error

- Fix build.yml4

- Fix build.yml3

- Fix build.yml2

- Fix build.yml

- Add search function at access control

- Fix the issues with the profile add button to cover the edit button

- Adapt LoadBalance and Relay

- Add arm

- Fix android notification icon error

- Add one-click update all profiles

- Add expire show

- Temp remove tun mode

- Remove macos in workflow

- Change go version

- Update Version

- Fix tun unable to open

- Optimize delay test2

- Optimize delay test

- Add check ip

- add check ip request

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the application to flash back.

- Fix edit profile error

- Fix quickStart change proxy error

- Fix core version

- Fix core version

- Update file_picker

- Add resources page

- Optimize more detail

- Add access selected sorted

- Fix notification duplicate creation issue

- Fix AccessControl click issue

- Fix Workflow

- Fix Linux unable to open

- Update README.md 3

- Create LICENSE

- Update README.md 2

- Update README.md

- Optimize workFlow

- optimize checkUpdate

- Fix submit error

- add WebDAV

- add Auto check updates

- Optimize more details

- optimize delayTest

- upgrade flutter version

- Update kernel

- Add import profile via QR code image

- Add compatibility mode and adapt clash scheme.

- update Version

- Reconstruction application proxy logic

- Fix Tab destroy error

- Optimize repeat healthcheck

- Optimize Direct mode ui

- Optimize Healthcheck

- Remove proxies position animation, improve performance

- Add Telegram Link

- Update healthcheck policy

- New Check URLTest

- Fix the problem of invalid auto-selection

- New Async UpdateConfig

- add changeProfileDebounce

- Update Workflow

- Fix ChangeProfile block

- Fix Release Message Error

- Update Selector 2

- Update Version

- Fix Proxies Select Error

- Fix the problem that the proxy group is empty in global mode.

- Fix the problem that the proxy group is empty in global mode.

- Add ProxyProvider2

- Add ProxyProvider

- Update Version

- Update ProxyGroup Sort

- Fix Android quickStart VpnService some problems

- Update version

- Set Android notification low importance

- Fix the issue that VpnService can't be closed correctly in special cases

- Fix the problem that TileService is not destroyed correctly in some cases

- Adjust tab animation defaults

- Add Telegram in README_zh_CN.md

- Add Telegram

- update mobile_scanner

- Initial commit

## v0.8.92

- Add sqlite store

- Optimize android quick action

- Optimize backup and restore

- Optimize more details

## v0.8.91

- Fix windows some issues

- Optimize overwrite handle

- Optimize access control page

- Optimize some details

## v0.8.90

- Fix android tile service

- Support append system DNS

- Fix some issues

- Update changelog

## v0.8.89

- Fix some issues

- Optimize Windows service mode

- Update core

- Update changelog

## v0.8.88

- Add android separates the core process

- Support core status check and force restart

- Optimize proxies page and access page

- Update flutter and pub dependencies

- Update go version

- Optimize more details

- Update changelog

## v0.8.87

- Optimize desktop view

- Optimize logs, requests, connection pages

- Optimize windows tray auto hide

- Optimize some details

- Update core

- Update changelog

## v0.8.86

- Fix windows tun issues

- Optimize android get system dns

- Optimize more details

- Update changelog

## v0.8.85

- Support override script

- Support proxies search

- Support svg display

- Optimize config persistence

- Add some scenes auto close connections

- Update core

- Optimize more details

## v0.8.84

- Fix windows service verify issues

- Update changelog

## v0.8.83

- Add windows server mode start process verify

- Add linux deb dependencies

- Add backup recovery strategy select

- Support custom text scaling

- Optimize the display of different text scale

- Optimize windows setup experience

- Optimize startTun performance

- Optimize android tv experience

- Optimize default option

- Optimize computed text size

- Optimize hyperOS freeform window

- Add developer mode

- Update core

- Optimize more details

- Add issues template

- Update changelog

## v0.8.82

- Optimize android vpn performance

- Add custom primary color and color scheme

- Add linux nad windows arm release

- Optimize requests and logs page

- Fix map input page delete issues

- Update changelog

## v0.8.81

- Add rule override

- Update core

- Optimize more details

- Update changelog

## v0.8.80

- Optimize dashboard performance

- Fix some issues

- Fix unselected proxy group delay issues

- Fix asn url issues

- Update changelog

## v0.8.79

- Fix tab delay view issues

- Fix tray action issues

- Fix get profile redirect client ua issues

- Fix proxy card delay view issues

- Add Russian, Japanese adaptation

- Fix some issues

- Update changelog

## v0.8.78

- Fix list form input view issues

- Fix traffic view issues

- Update changelog

## v0.8.77

- Optimize performance

- Update core

- Optimize core stability

- Fix linux tun authority check error

- Fix some issues

- Fix scroll physics error

- Update changelog

## v0.8.75

- Add windows storage corruption detection

- Fix core crash caused by windows resource manager restart

- Optimize logs, requests, access to pages

- Fix macos bypass domain issues

- Update changelog

## v0.8.74

- Fix some issues

- Update changelog

## v0.8.73

- Update popup menu

- Add file editor

- Fix android service issues

- Optimize desktop background performance

- Optimize android main process performance

- Optimize delay test

- Optimize vpn protect

- Update changelog

## v0.8.72

- Update core

- Fix some issues

- Update changelog

## v0.8.71

- Remake dashboard

- Optimize theme

- Optimize more details

- Update flutter version

- Update changelog

## v0.8.70

- Support better window position memory

- Add windows arm64 and linux arm64 build script

- Optimize some details

## v0.8.69

- Remake desktop

- Optimize change proxy

- Optimize network check

- Fix fallback issues

- Optimize lots of details

- Update change.yaml

- Fix android tile issues

- Fix windows tray issues

- Support setting bypassDomain

- Update flutter version

- Fix android service issues

- Fix macos dock exit button issues

- Add route address setting

- Optimize provider view

- Update changelog

- Update CHANGELOG.md

## v0.8.67

- Add android shortcuts

- Fix init params issues

- Fix dynamic color issues

- Optimize navigator animate

- Optimize window init

- Optimize fab

- Optimize save

## v0.8.66

- Fix the collapse issues

- Add fontFamily options

## v0.8.65

- Update core version

- Update flutter version

- Optimize ip check

- Optimize url-test

## v0.8.64

- Update release message

- Init auto gen changelog

- Fix windows tray issues

- Fix urltest issues

- Add auto changelog

- Fix windows admin auto launch issues

- Add android vpn options

- Support proxies icon configuration

- Optimize android immersion display

- Fix some issues

- Optimize ip detection

- Support android vpn ipv6 inbound switch

- Support log export

- Optimize more details

- Fix android system dns issues

- Optimize dns default option

- Fix some issues

- Update readme

## v0.8.60

- Fix build error2

- Fix build error

- Support desktop hotkey

- Support android ipv6 inbound

- Support android system dns

- fix some bugs

## v0.8.59

- Fix delete profile error

## v0.8.58

- Fix submit error 2

- Fix submit error

- Optimize DNS strategy

- Fix the problem that the tray is not displayed in some cases

- Optimize tray

- Update core

- Fix some error

## v0.8.57

- Fix tun update issues

- Add DNS override
- Fixed some bugs
- Optimize more detail

- Add Hosts override

## v0.8.56

- fix android tip error
- fix windows auto launch error

## v0.8.55

- Fix windows tray issues

- Optimize windows logic

- Optimize app logic

- Support windows administrator auto launch

- Support android close vpn

## v0.8.53

- Change flutter version

- Support profiles sort

- Support windows country flags display

- Optimize proxies page and profiles page columns

## v0.8.52

- Update flutter version

- Update version

- Update timeout time

- Update access control page

- Fix bug

## v0.8.51

- Optimize provider page

- Optimize delay test

- Support local backup and recovery

- Fix android tile service issues

## v0.8.49

- Fix linux core build error

- Add proxy-only traffic statistics

- Update core

- Optimize more details

- Merge pull request #140 from txyyh/main

- 添加自建 F-Droid 仓库相关 workflow
- Rename readme fingerprint

- Rename workflow deploy repo name

- Add download guide to README

- Add push release files to fdroid-repo

## v0.8.48

- Optimize proxies page

- Fix ua issues

- Optimize more details

## v0.8.47

- Fix windows build error

## v0.8.46

- Update app icon

- Fix desktop backup error

- Optimize request ua

- Change android icon

- Optimize dashboard

## v0.8.44

- Remove request validate certificate

- Sync core

## v0.8.43

- Fix windows error

## v0.8.42

- Fix setup.dart error

- Fix android system proxy not effective

- Add macos arm64

## v0.8.41

- Optimize proxies page

- Support mouse drag scroll

- Adjust desktop ui

- Revert "Fix android vpn issues"

- This reverts commit 891977408e6938e2acd74e9b9adb959c48c79988.

## v0.8.40

- Fix android vpn issues

- Fix android vpn issues

- Rollback partial modification

## v0.8.39

- Fix the problem that ui can't be synchronized when android vpn is occupied by an external

- Override default socksPort,port

## v0.8.38

- Fix fab issues

## v0.8.37

- Update version

- Fix the problem that vpn cannot be started in some cases

- Fix the problem that geodata url does not take effect

## v0.8.36

- Update ua

- Fix change outbound mode without check ip issues

- Separate android ui and vpn

- Fix url validate issues 2

- Add android hidden from the recent task

- Add geoip file

- Support modify geoData URL

## v0.8.35

- Fix url validate issues

- Fix check ip performance problem

- Optimize resources page

## v0.8.34

- Add ua selector

- Support modify test url

- Optimize android proxy

- Fix the error that async proxy provider could not selected the proxy

## v0.8.33

- Fix android proxy error

- Fix submit error

- Add windows tun

- Optimize android proxy

- Optimize change profile

- Update application ua

- Optimize delay test

## v0.8.32

- Fix android repeated request notification issues

## v0.8.31

- Fix memory overflow issues

## v0.8.30

- Optimize proxies expansion panel 2

- Fix android scan qrcode error

## v0.8.29

- Optimize proxies expansion panel

- Fix text error

## v0.8.28

- Optimize proxy

- Optimize delayed sorting performance

- Add expansion panel proxies page

- Support to adjust the proxy card size

- Support to adjust proxies columns number

- Fix autoRun show issues

- Fix Android 10 issues

- Optimize ip show

## v0.8.26

- Add intranet IP display

- Add connections page

- Add search in connections, requests

- Add keyword search in connections, requests, logs

- Add basic viewing editing capabilities

- Optimize update profile

## v0.8.25

- Update version

- Fix the problem of excessive memory usage in traffic usage.

- Add lightBlue theme color

- Fix start unable to update profile issues

- Fix flashback caused by process

## v0.8.23

- Add build version

- Optimize quick start

- Update system default option

## v0.8.22

- Update build.yml

- Fix android vpn close issues

- Add requests page

- Fix checkUpdate dark mode style error

- Fix quickStart error open app

- Add memory proxies tab index

- Support hidden group

- Optimize logs

- Fix externalController hot load error

## v0.8.21

- Add tcp concurrent switch

- Add system proxy switch

- Add geodata loader switch

- Add external controller switch

- Add auto gc on trim memory

- Fix android notification error

## v0.8.20

- Fix ipv6 error

- Fix android udp direct error

- Add ipv6 switch

- Add access all selected button

- Remove android low version splash

## v0.8.19

- Update version

- Add allowBypass

- Fix Android only pick .text file issues

## v0.8.18

- Fix search issues

## v0.8.17

- Fix LoadBalance, Relay load error

- Fix build.yml4

- Fix build.yml3

- Fix build.yml2

- Fix build.yml

- Add search function at access control

- Fix the issues with the profile add button to cover the edit button

- Adapt LoadBalance and Relay

- Add arm

- Fix android notification icon error

## v0.8.16

- Add one-click update all profiles
- Add expire show

## v0.8.15

- Temp remove tun mode

- Remove macos in workflow

- Change go version

## v0.8.14

- Update Version

- Fix tun unable to open

## v0.8.13

- Optimize delay test2

- Optimize delay test

- Add check ip

- add check ip request

## v0.8.12

- Fix the problem that the download of remote resources failed after GeodataMode was turned on, which caused the
  application to flash back.

- Fix edit profile error

- Fix quickStart change proxy error

- Fix core version

## v0.8.10

- Fix core version

## v0.8.9

- Update file_picker

- Add resources page

- Optimize more detail

- Add access selected sorted

- Fix notification duplicate creation issue

- Fix AccessControl click issue

## v0.8.7

- Fix Workflow

- Fix Linux unable to open

- Update README.md 3

- Create LICENSE
- Update README.md 2

- Update README.md

- Optimize workFlow

## v0.8.6

- optimize checkUpdate

## v0.8.5

- Fix submit error

## v0.8.4

- add WebDAV

- add Auto check updates

- Optimize more details

- optimize delayTest

## v0.8.2

- upgrade flutter version

## v0.8.1

- Update kernel
- Add import profile via QR code image

## v0.8.0

- Add compatibility mode and adapt clash scheme.

## v0.7.14

- update Version

- Reconstruction application proxy logic

## v0.7.13

- Fix Tab destroy error

## v0.7.12

- Optimize repeat healthcheck

## v0.7.11

- Optimize Direct mode ui

## v0.7.10

- Optimize Healthcheck

- Remove proxies position animation, improve performance
- Add Telegram Link

- Update healthcheck policy

- New Check URLTest

- Fix the problem of invalid auto-selection

## v0.7.8

- New Async UpdateConfig

- add changeProfileDebounce

- Update Workflow

- Fix ChangeProfile block

- Fix Release Message Error

## v0.7.7

- Update Selector 2

## v0.7.6

- Update Version

- Fix Proxies Select Error

## v0.7.5

- Fix the problem that the proxy group is empty in global mode.

- Fix the problem that the proxy group is empty in global mode.

## v0.7.4

- Add ProxyProvider2

## v0.7.3

- Add ProxyProvider

- Update Version

- Update ProxyGroup Sort

- Fix Android quickStart VpnService some problems

## v0.7.1

- Update version

- Set Android notification low importance

- Fix the issue that VpnService can't be closed correctly in special cases

- Fix the problem that TileService is not destroyed correctly in some cases

- Adjust tab animation defaults

- Add Telegram in README_zh_CN.md

- Add Telegram

## v0.7.0

- update mobile_scanner

- Initial commit