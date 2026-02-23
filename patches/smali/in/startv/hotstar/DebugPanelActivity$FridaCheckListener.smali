.class public Lin/startv/hotstar/DebugPanelActivity$FridaCheckListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# interfaces
.implements Landroid/view/View$OnClickListener;

# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/DebugPanelActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FridaCheckListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$FridaCheckListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$FridaCheckListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "========================================\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "    FRIDA GADGET STATUS REPORT\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "========================================\n\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 1. Check if frida-gadget is in /proc/self/maps
    const-string v2, "\u2460 Gadget Library Status:\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "grep -c frida /proc/self/maps 2>/dev/null"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v2

    const-string v3, "0"
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v3
    if-nez v3, :frida_not_loaded

    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z
    move-result v3
    if-nez v3, :frida_not_loaded

    # Frida loaded
    const-string v2, "  \u2705 Frida Gadget: LOADED in process\n\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :frida_check_done

    :frida_not_loaded
    const-string v2, "  \u274c Frida Gadget: NOT LOADED in process\n\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :frida_check_done

    # 2. Show frida-related memory map entries
    const-string v2, "\u2461 Memory Maps (frida entries):\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "grep frida /proc/self/maps 2>/dev/null || echo '  (none found)'"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 3. Check frida-gadget.so and config in app dirs
    const-string v2, "\n\u2462 Gadget Files on Disk:\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "find /data/app/ -name '*frida*' -o -name '*.config.so' 2>/dev/null | head -10; echo '---'; ls -la /data/local/tmp/frida* 2>/dev/null || echo '  (nothing in /data/local/tmp/)'"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 4. Read gadget config if exists
    const-string v2, "\n\u2463 Gadget Config Content:\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "for f in $(find /data/app/ -name '*.config.so' 2>/dev/null); do echo \"=== $f ===\"; cat \"$f\" 2>/dev/null; echo; done; if [ -z \"$(find /data/app/ -name '*.config.so' 2>/dev/null)\" ]; then echo '  (no config file found)'; fi"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 5. SELinux status
    const-string v2, "\n\u2464 SELinux Status:\n  "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "getenforce 2>/dev/null || echo '(unable to check)'"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 6. Recent Frida logcat entries
    const-string v2, "\n\u2465 Recent Frida Logcat:\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "logcat -d -t 100 2>/dev/null | grep -iE 'frida|gadget|HSPatch.*[Ff]rida|HSPatch.*LOADED|HSPatch.*FAILED' | tail -15 || echo '  (no frida log entries)'"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 7. JS engine check in process memory
    const-string v2, "\n\u2466 JS Engine in Process:\n  "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "V8_COUNT=$(grep -c 'v8.*snapshot\\|libv8' /proc/self/maps 2>/dev/null); DUK_COUNT=$(grep -c 'duktape' /proc/self/maps 2>/dev/null); QJS_COUNT=$(grep -c 'quickjs' /proc/self/maps 2>/dev/null); if [ \"$V8_COUNT\" != \"0\" ] 2>/dev/null; then echo \"V8 engine: $V8_COUNT entries\"; elif [ \"$DUK_COUNT\" != \"0\" ] 2>/dev/null; then echo \"Duktape engine: $DUK_COUNT entries\"; elif [ \"$QJS_COUNT\" != \"0\" ] 2>/dev/null; then echo \"QuickJS engine: $QJS_COUNT entries\"; else echo 'No JS engine found in process maps'; fi"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # 8. HSPatch log entries
    const-string v2, "\n\u2467 All HSPatch Init Logs:\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "logcat -d -t 200 2>/dev/null | grep 'HSPatch' | tail -20 || echo '  (no HSPatch entries)'"
    invoke-static {v2}, Lin/startv/hotstar/ProfileManager;->shellExecOutput(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, "\n======== END REPORT ========\n"
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    # Show in log view
    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1

    iget-object v2, v0, Lin/startv/hotstar/DebugPanelActivity;->logView:Landroid/widget/TextView;
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Clear current log file
    const/4 v1, 0x0
    iput-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->currentLogFile:Ljava/lang/String;

    # Scroll to top
    iget-object v1, v0, Lin/startv/hotstar/DebugPanelActivity;->logScrollView:Landroid/widget/ScrollView;
    if-eqz v1, :done
    const/16 v2, 0x21
    invoke-virtual {v1, v2}, Landroid/widget/ScrollView;->fullScroll(I)Z

    :done
    return-void
.end method
