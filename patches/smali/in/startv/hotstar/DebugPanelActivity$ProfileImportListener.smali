.class public Lin/startv/hotstar/DebugPanelActivity$ProfileImportListener;
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
    name = "ProfileImportListener"
.end annotation


# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;


# direct methods
.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileImportListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    return-void
.end method


# virtual methods
.method public onClick(Landroid/view/View;)V
    .locals 5

    iget-object v0, p0, Lin/startv/hotstar/DebugPanelActivity$ProfileImportListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    :try_start
    # Launch SAF file picker (no storage permission needed)
    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.OPEN_DOCUMENT"
    invoke-direct {v1, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    # Add CATEGORY_OPENABLE
    const-string v2, "android.intent.category.OPENABLE"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->addCategory(Ljava/lang/String;)Landroid/content/Intent;

    # setType("*/*") — broadest filter, refined by EXTRA_MIME_TYPES
    const-string v2, "*/*"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->setType(Ljava/lang/String;)Landroid/content/Intent;

    # Set MIME type filters: zip + gzip + octet-stream (catches renamed zips)
    const/4 v2, 0x4
    new-array v2, v2, [Ljava/lang/String;
    const/4 v3, 0x0
    const-string v4, "application/zip"
    aput-object v4, v2, v3
    const/4 v3, 0x1
    const-string v4, "application/gzip"
    aput-object v4, v2, v3
    const/4 v3, 0x2
    const-string v4, "application/x-gzip"
    aput-object v4, v2, v3
    const/4 v3, 0x3
    const-string v4, "application/octet-stream"
    aput-object v4, v2, v3

    const-string v3, "android.intent.extra.MIME_TYPES"
    invoke-virtual {v1, v3, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;[Ljava/lang/String;)Landroid/content/Intent;

    # REQUEST_CODE = 42 (0x2A) for profile import
    const/16 v2, 0x2a
    invoke-virtual {v0, v1, v2}, Landroid/app/Activity;->startActivityForResult(Landroid/content/Intent;I)V
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch

    goto :done

    :catch
    move-exception v1
    # Fallback: no file manager available
    const-string v2, "No file manager found.\nPlease install a file manager app."
    const/4 v3, 0x1
    invoke-static {v0, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v2
    invoke-virtual {v2}, Landroid/widget/Toast;->show()V

    :done
    return-void
.end method
