import 'package:flutter/material.dart';
import 'package:fl_clash/common/constant.dart' as c;

/// 简易中英双语国际化
class S {
  static Locale _locale = const Locale('zh');
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(_locale);

  static Locale get locale => _locale;
  static bool get isEn => _locale.languageCode == 'en';

  static void setLocale(Locale l) {
    _locale = l;
    localeNotifier.value = l;
  }

  static void toggle() {
    setLocale(isEn ? const Locale('zh') : const Locale('en'));
  }

  // ── 通用 ──
  static String get appName => c.appName;
  static String get confirm => isEn ? 'Confirm' : '确认';
  static String get cancel => isEn ? 'Cancel' : '取消';
  static String get devInProgress => isEn ? 'Feature in development' : '功能开发中';
  static String get dataRefreshed => isEn ? 'Data refreshed' : '数据已刷新';

  // ── 导航 ──
  static String get navHome => isEn ? 'Home' : '首页';
  static String get navNodes => isEn ? 'Nodes' : '节点';
  static String get navPlans => isEn ? 'Plans' : '套餐';
  static String get navProfile => isEn ? 'Profile' : '我的';

  // ── 首页 ──
  static String get tapToConnect => isEn ? 'Tap to Connect' : '点击连接';
  static String get protected_ => isEn ? 'Protected' : '已保护';
  static String get upload => isEn ? 'Upload' : '上传';
  static String get download => isEn ? 'Download' : '下载';
  static String get systemNotice => isEn ? 'Announcements' : '系统公告';

  // ── 节点页 ──
  static String get selectNode => isEn ? 'Select Node' : '选择节点';
  static String get subscribe => isEn ? 'Sync' : '订阅';
  static String get speedTest => isEn ? 'Test' : '测速';
  static String get sort => isEn ? 'Sort' : '排序';
  static String get smartSelect => isEn ? 'Smart Select' : '智能选择';
  static String get smartSelectDesc => isEn ? 'Auto-select lowest latency node' : '自动选择延迟最低的节点';
  static String get loginToViewNodes => isEn ? 'Login to view nodes' : '登录后查看节点';
  static String get loginToViewNodesDesc => isEn ? 'Login and purchase a plan\nto view all available nodes' : '登录并购买套餐后\n即可查看全部可用节点';

  // ── 我的 ──
  static String get myPage => isEn ? 'Profile' : '我的';
  static String get guestMode => isEn ? 'Guest Mode' : '游客模式';
  static String get loginForFull => isEn ? 'Login for full access' : '登录后享受全部功能';
  static String get login => isEn ? 'Login' : '登录';
  static String get register => isEn ? 'Register' : '注册';
  static String get loginMihom => isEn ? 'Login ${c.appName}' : '登录 ${c.appName}';
  static String get registerMihom => isEn ? 'Register ${c.appName}' : '注册 ${c.appName}';
  static String get emailAddress => isEn ? 'Email' : '邮箱地址';
  static String get password => isEn ? 'Password' : '密码';
  static String get noAccount => isEn ? 'No account? ' : '没有账号？';
  static String get goRegister => isEn ? 'Register' : '去注册';
  static String get hasAccount => isEn ? 'Already have an account? ' : '已有账号？';
  static String get goLogin => isEn ? 'Login' : '去登录';
  static String get loginFirst => isEn ? 'Please login first to connect' : '请先登录后再连接节点';
  static String get loginToBuy => isEn ? 'Login to purchase plan' : '登录后即可购买套餐';
  static String get loginToInvite => isEn ? 'Login to invite friends' : '登录后可邀请好友获得奖励';
  static String get loginToViewOrders => isEn ? 'Login to view orders' : '登录后查看订单记录';
  static String get loginToViewNodesHint => isEn ? 'Login to view available nodes' : '登录后可查看可用节点';
  static String get loginOrRegister => isEn ? 'Login / Register' : '登录 / 注册';
  static String get vipMember => isEn ? 'Annual VIP · ID: 10086' : '年费会员 · ID: 10086';
  static String get userName => isEn ? 'Wujie User' : '无界用户';
  static String get balance => isEn ? 'Balance' : '账户余额';
  static String get recharge => isEn ? 'Recharge' : '充值';
  static String get inviteFriends => isEn ? 'Invite' : '邀请好友';
  static String get buyPlan => isEn ? 'Plans' : '购买套餐';
  static String get myOrders => isEn ? 'Orders' : '我的订单';
  static String get usageHistory => isEn ? 'Usage History' : '使用记录';
  static String get usageHistoryDesc => isEn ? 'View traffic usage details' : '查看流量使用详情';
  static String get giftCard => isEn ? 'Gift Card' : '礼品卡兑换';
  static String get giftCardDesc => isEn ? 'Redeem gift card code' : '输入兑换码使用';
  static String get onlineSupport => isEn ? 'Support' : '在线客服';
  static String get onlineSupportDesc => isEn ? '24/7 Customer Service' : '7×24 小时客服';
  static String get helpCenter => isEn ? 'Help' : '帮助中心';
  static String get helpCenterDesc => isEn ? 'FAQ' : '常见问题';
  static String get checkUpdate => isEn ? 'Check Update' : '检测更新';
  static String get logout => isEn ? 'Logout' : '退出登录';
  static String get logoutConfirm => isEn ? 'Confirm logout?' : '确认退出登录？';
  static String get logoutDesc => isEn ? 'You will return to guest mode after logout' : '退出后将回到游客模式';

  // ── 设置 ──
  static String get settings => isEn ? 'Settings' : '设置';
  static String get proxy => isEn ? 'Proxy' : '代理';
  static String get proxyMode => isEn ? 'Proxy Mode' : '代理模式';
  static String get ruleMode => isEn ? 'Rule' : '规则';
  static String get globalMode => isEn ? 'Global' : '全局';
  static String get campusMode => isEn ? 'Campus' : '校园网';
  static String get ruleModeTitle => isEn ? 'Rule Mode' : '规则模式';
  static String get ruleModeDesc => isEn
      ? 'Routes traffic based on predefined rules. Domestic sites connect directly for speed, while blocked/foreign sites go through the proxy. Best balance between speed and accessibility for most users.'
      : '根据预设规则智能分流。国内网站直连保证速度，被屏蔽或海外网站走代理访问。兼顾速度与可访问性，适合大多数用户日常使用。';
  static String get ruleModeFeatures => isEn ? 'How it works:' : '工作原理：';
  static String get globalModeTitle => isEn ? 'Global Mode' : '全局模式';
  static String get globalModeDesc => isEn
      ? 'All traffic goes through the proxy server. No exceptions. Provides maximum privacy and ensures all connections are encrypted, but may slow down access to domestic sites. Use when you need full anonymity or in restrictive networks.'
      : '所有流量均通过代理服务器转发，无任何例外。提供最大隐私保护，确保所有连接加密，但可能降低国内网站访问速度。适用于需要完全匿名或在严格受限网络环境中使用。';
  static String get globalModeFeatures => isEn ? 'Characteristics:' : '特点：';
  static String get campusModeTitle => isEn ? 'Campus Network Mode' : '校园网模式';
  static String get campusModeDesc => isEn
      ? 'Optimized for campus networks. Disables TUN mode and uses system proxy instead, so campus authentication portals (Srun/Ruijie) work normally. Campus domains bypass the proxy for direct access, while external traffic goes through the proxy via rule mode.'
      : '专为校园网环境优化。关闭 TUN 模式改用系统代理，确保校园网认证门户（深澜/锐捷）正常弹出登录。校园域名走系统代理旁路直连，校外流量按规则模式走代理。退出校园网模式时自动恢复 TUN 设置。';
  static String get campusEnabled => isEn ? 'Campus mode: TUN off, system proxy on' : '校园网模式：已关闭TUN，启用系统代理';
  static String get campusDisabled => isEn ? 'Campus mode disabled' : '已关闭校园网模式';
  static String get campusBypassDomains => isEn ? 'Campus Bypass Domains' : '校园网直连域名';
  static String get campusBypassDomainsDesc => isEn
      ? 'These domains will connect directly without proxy:'
      : '以下域名将直连不走代理：';
  static String get customDns => isEn ? 'Custom DNS' : '自定义 DNS';
  static String get perAppProxy => isEn ? 'Per-app Proxy' : '分应用代理';
  static String get general => isEn ? 'General' : '通用';
  static String get darkMode => isEn ? 'Dark Mode' : '深色模式';
  static String get followSystem => isEn ? 'Follow System' : '跟随系统';
  static String get language => isEn ? 'Language' : '语言';
  static String get themeStyle => isEn ? 'Theme' : '主题风格';
  static String get autoStart => isEn ? 'Auto Start' : '开机启动';
  static String get network => isEn ? 'Network' : '网络';
  static String get webdavSync => isEn ? 'WebDAV Sync' : 'WebDAV 同步';
  static String get tunMode => isEn ? 'TUN Mode' : 'TUN 模式';
  static String get other => isEn ? 'Other' : '其他';
  static String get debugLog => isEn ? 'Debug Log' : '调试日志';
  static String get clearCache => isEn ? 'Clear Cache' : '清除缓存';
  static String get cacheCleared => isEn ? 'Cache cleared' : '缓存已清除';

  // ── 更新弹窗 ──
  static String get newVersion => isEn ? 'New Version Available' : '发现新版本';
  static String get updateNow => isEn ? 'Update Now' : '立即更新';
  static String get updateLater => isEn ? 'Later' : '稍后更新';
  static String get changelog => isEn ? 'Changelog' : '更新日志';
  static String get downloading => isEn ? 'Downloading in background...' : '后台下载中...';
  static String get packageSize => isEn ? 'Package size' : '安装包大小';
  static String get updateLog1 => isEn ? 'Added WireGuard protocol support' : '新增 WireGuard 协议支持';
  static String get updateLog2 => isEn ? 'Improved node speed test accuracy' : '优化节点测速精准度';
  static String get updateLog3 => isEn ? 'Fixed unstable connection on some devices' : '修复部分设备连接不稳定问题';
  static String get updateLog4 => isEn ? 'Auto-switch to optimal node' : '新增自动切换最优节点';
  static String get updateLog5 => isEn ? 'UI refinements & performance boost' : 'UI 细节优化与性能提升';

  // ── 套餐页 ──
  static String get plans => isEn ? 'Buy Plans' : '购买套餐';
  static String get allPlans => isEn ? 'All' : '全部';
  static String get recurring => isEn ? 'Recurring' : '周期套餐';
  static String get oneTime => isEn ? 'One-time' : '一次性';

  // ── TG ──
  static String get bindTg => isEn ? 'Bind Telegram' : 'TG 群绑定';
  static String get notBound => isEn ? 'Not Bound' : '未绑定';

  // ── 主题选择 ──
  static String get selectTheme => isEn ? 'Select Theme' : '选择主题风格';
  static String get enterMihom => isEn ? 'Enter ${c.appName}' : '进入 ${c.appName}';
  static String get selectYourStyle => isEn ? 'Choose your style' : '选择你喜欢的风格';
  static String get uiStyle => isEn ? 'UI Style' : 'UI 风格';
  static String get canSwitchLater => isEn ? 'Can switch anytime in Settings' : '可随时在设置中切换';

  // ── 礼品卡弹窗 ──
  static String get giftCardTitle => isEn ? 'Redeem Gift Card' : '礼品卡兑换';
  static String get giftCardHint => isEn ? 'Enter gift card code' : '请输入礼品卡兑换码';
  static String get redeem => isEn ? 'Redeem' : '兑换';
  static String get redeemSuccess => isEn ? 'Gift card redeemed successfully!' : '礼品卡兑换成功！';
  static String get giftCardEmpty => isEn ? 'Please enter gift card code' : '请输入礼品卡兑换码';

  static String get connectionTime => isEn ? 'Connection Time' : '连接时间';

  // ── 首页警告 ──
  static String get planExpirySoon => isEn ? 'Plan expires in 3 days' : '套餐将在 3 天后到期';
  static String get trafficUsed85 => isEn ? '85% traffic used (42.5/50 GB)' : '流量已使用 85%（42.5/50 GB）';
  static String get renew => isEn ? 'Renew' : '续费';
  static String get upgrade => isEn ? 'Upgrade' : '升级';

  // ── 个人页扩展 ──
  static String get usedTraffic => isEn ? 'Used Traffic' : '已用流量';
  static String get expiresDate => isEn ? 'Expires 2026-12-31' : '到期 2026-12-31';
  static String get remainingDays => isEn ? '271 days left' : '剩余 271 天';
  static String get bindTgDesc => isEn ? 'Receive group notifications and latest offers' : '绑定后可接收群组通知、获取最新优惠信息';
  static String get goToBind => isEn ? 'Go to Bind' : '前往绑定';
  static String get tgLinkCopied => isEn ? 'TG group link copied' : 'TG 群链接已复制';

  // ── 节点页扩展 ──
  static String get nodeListUpdated => isEn ? 'Node list updated' : '节点列表已更新';
  static String get syncingSubscriptions => isEn ? 'Syncing subscriptions...' : '正在更新订阅...';
  static String get testingSpeed => isEn ? 'Testing speed...' : '正在测速，请稍候...';
  static String get sortedByLatency => isEn ? 'Sorted by latency' : '已按延迟排序';

  // ── 套餐页 ──
  static String get selectPlan => isEn ? 'Select Plan' : '选择套餐';
  static String get accountBalance => isEn ? 'Account Balance' : '账户余额';
  static String get recommended => isEn ? 'Hot' : '推荐';
  static String get perMonth => isEn ? '/mo' : '/月';
  static String get fromPerMonth => isEn ? '/mo' : '/月起';
  static String get oneTimeLabel => isEn ? 'One-time' : '一次性';
  static String get selectBillingCycle => isEn ? 'Select Billing Cycle' : '选择订阅周期';
  static String get pleaseSelectCycle => isEn ? 'Select a cycle' : '请选择周期';
  static String get haveCoupon => isEn ? 'Have a coupon?' : '有优惠码？';
  static String get tapToInput => isEn ? 'Tap to enter' : '点击输入';
  static String get enterCouponCode => isEn ? 'Enter coupon code' : '输入优惠码';
  static String get verifiedLabel => isEn ? 'Verified' : '已核销';
  static String get verifyLabel => isEn ? 'Verify' : '核销';
  static String get verifyCouponFirst => isEn ? 'Verify coupon first, or clear input' : '请先核销优惠码，或清空输入';
  static String get coupon10Off => isEn ? '10% off applied' : '已享 9 折优惠';
  static String get originalPriceLabel => isEn ? 'Original price' : '套餐原价';
  static String get couponLabel => isEn ? 'Coupon' : '优惠码';
  static String get pendingVerify => isEn ? 'Pending' : '待核销';
  static String get amountDue => isEn ? 'Amount Due' : '应付金额';
  static String get buyNow => isEn ? 'Buy Now' : '立即购买';
  static String get waitingPayment => isEn ? 'Waiting for payment...' : '等待支付结果...';
  static String get purchaseSuccess => isEn ? 'Purchase Successful!' : '购买成功！';
  static String get okStartConnect => isEn ? 'OK, Start Connecting' : '好的，开始连接';
  static String get selectPaymentMethod => isEn ? 'Select Payment' : '选择支付方式';
  static String get pleaseSelectPayment => isEn ? 'Select a payment method' : '请选择支付方式';
  static String get plansUpdated => isEn ? 'Plans updated' : '套餐已更新';
  static String get planBenefits => isEn ? 'Plan Benefits' : '套餐权益';
  static String get paid => isEn ? 'Paid' : '已支付';
  static String get paymentMethod => isEn ? 'Payment' : '支付方式';
  static String get expiryTime => isEn ? 'Expires' : '到期时间';
  static String get trafficLabel => isEn ? 'Traffic' : '流量';
  static String get planLabel => isEn ? 'Plan' : '套餐';
  static String get cycleLabel => isEn ? 'Cycle' : '周期';
  static String get noActivePlan => isEn ? 'No Active Plan' : '暂无套餐';
  static String get needPurchasePlan => isEn ? 'You need to purchase a plan\nbefore connecting to nodes.' : '您还没有购买套餐\n请先购买套餐后再连接节点';
  static String get discountLabel => isEn ? '% off' : '折';
  static String get equivalentMonthly => isEn ? 'eq.' : '折合';
  static String get confirmPaymentWithPrice => isEn ? 'Confirm Payment' : '确认支付';

  // ── 套餐周期 ──
  static String get monthlyPlan => isEn ? '1 Month' : '月付';
  static String get quarterlyPlan => isEn ? '3 Months' : '季付';
  static String get semiAnnualPlan => isEn ? '6 Months' : '半年付';
  static String get annualPlan => isEn ? '12 Months' : '年付';

  static String get orderDetails => isEn ? 'Order Details' : '订单详情';

  // ── 支付方式 ──
  static String get alipay => isEn ? 'Alipay' : '支付宝';
  static String get wechatPay => isEn ? 'WeChat Pay' : '微信支付';
  static String get balancePay => isEn ? 'Balance Pay' : '余额支付';

  // ── 套餐名称 ──
  static String get planLite => isEn ? 'Lite' : '轻量入门';
  static String get planLiteDesc => isEn ? 'For light use' : '适合轻度使用';
  static String get planStandard => isEn ? 'Standard' : '标准套餐';
  static String get planStandardDesc => isEn ? 'Best for daily use' : '日常使用推荐';
  static String get planPro => isEn ? 'Pro' : '专业套餐';
  static String get planProDesc => isEn ? 'For heavy users' : '重度用户首选';
  static String get planUnlimited => isEn ? 'Unlimited' : '不限量套餐';
  static String get planUnlimitedDesc => isEn ? 'No limits' : '无限制体验';
  static String get planTrial => isEn ? 'Trial Pack' : '体验包';
  static String get planTrialDesc => isEn ? 'Short trial' : '短期体验';
  static String get planBooster => isEn ? 'Traffic Booster' : '流量加油包';
  static String get planBoosterDesc => isEn ? 'Extra traffic' : '临时补充流量';
  static String get unlimited => isEn ? 'Unlimited' : '不限量';

  // ── 套餐特性 ──
  static String get feat30gb => isEn ? '30 GB high-speed traffic' : '30 GB 高速流量';
  static String get feat100gb => isEn ? '100 GB high-speed traffic' : '100 GB 高速流量';
  static String get feat200gb => isEn ? '200 GB high-speed traffic' : '200 GB 高速流量';
  static String get featUnlimitedTraffic => isEn ? 'Unlimited high-speed traffic' : '不限量高速流量';
  static String get feat10gb => isEn ? '10 GB traffic' : '10 GB 流量';
  static String get feat50gbBoost => isEn ? '50 GB extra traffic' : '50 GB 叠加流量';
  static String get featAllNodes => isEn ? 'All nodes available' : '全部节点可用';
  static String get featAllNodesPremium => isEn ? 'All nodes + premium lines' : '全部节点 + 专线';
  static String get feat2Devices => isEn ? '2 devices online' : '2 台设备同时在线';
  static String get feat3Devices => isEn ? '3 devices online' : '3 台设备同时在线';
  static String get feat5Devices => isEn ? '5 devices online' : '5 台设备同时在线';
  static String get featUnlimitedDevices => isEn ? 'Unlimited devices' : '不限设备数量';
  static String get feat1Device => isEn ? '1 device' : '1 台设备';
  static String get featPrioritySupport => isEn ? 'Priority support' : '优先客服通道';
  static String get featDedicatedSupport => isEn ? 'Dedicated support' : '专属客服';
  static String get featFreeUpgrade => isEn ? 'Free upgrades' : '免费升级';
  static String get featNoExpiry => isEn ? 'No expiry' : '不限时间';
  static String get feat3DayValid => isEn ? 'Valid for 3 days' : '有效期 3 天';
  static String get featAllNodesBasic => isEn ? 'All nodes' : '全部节点';

  // ── 邀请页 ──
  static String get inviteTitle => isEn ? 'Invite Friends Together' : '邀请好友  一起加速';
  static String get inviteRewardDesc => isEn ? 'Invite 1 friend, both get 10 GB traffic' : '每成功邀请 1 位好友，双方各得 10 GB 流量';
  static String get invited => isEn ? 'Invited' : '已邀请';
  static String get people => isEn ? '' : '人';
  static String get trafficEarned => isEn ? 'Traffic Earned' : '获得流量';
  static String get commission => isEn ? 'Commission' : '佣金';
  static String get myInviteCode => isEn ? 'My Invite Code' : '我的邀请码';
  static String get inviteCodeCopied => isEn ? 'Invite code copied' : '邀请码已复制';
  static String get inviteLinkCopied => isEn ? 'Invite link copied' : '邀请链接已复制到剪贴板';
  static String get shareInviteLink => isEn ? 'Share Invite Link' : '分享邀请链接';
  static String get inviteRecords => isEn ? 'Invite Records' : '邀请记录';

  // ── 流量记录弹窗 ──
  static String get usageHistoryTitle => isEn ? 'Usage History' : '使用记录';
  static String get today => isEn ? 'Today' : '今天';
  static String get yesterday => isEn ? 'Yesterday' : '昨天';
  static String get totalUsed => isEn ? 'Total Used' : '已使用总量';
  static String get noUsageData => isEn ? 'No usage data' : '暂无使用记录';
}
