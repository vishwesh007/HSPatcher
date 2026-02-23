.class public Lin/startv/hotstar/FileExplorerActivity;
.super Landroid/app/Activity;
.source "FileExplorerActivity.java"


# instance fields
.field public currentPath:Ljava/lang/String;
.field public fileListLayout:Landroid/widget/LinearLayout;
.field public breadcrumbLayout:Landroid/widget/HorizontalScrollView;
.field public breadcrumbText:Landroid/widget/TextView;
.field public fileListScroll:Landroid/widget/ScrollView;
.field public statusText:Landroid/widget/TextView;
.field public rootPath:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method


# ===== HELPER: Get file size as human-readable string =====
.method public static formatSize(J)Ljava/lang/String;
    .locals 4

    # p0-p1 = long size
    # Check >= 1GB (1073741824)
    const-wide/32 v0, 0x40000000
    cmp-long v2, p0, v0
    if-ltz v2, :check_mb

    long-to-double v0, p0
    const-wide v2, 0x41d0000000000000L    # 1073741824.0 as double
    div-double/2addr v0, v2
    invoke-static {v0, v1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;
    move-result-object v0
    const/4 v1, 0x1
    new-array v1, v1, [Ljava/lang/Object;
    const/4 v2, 0x0
    aput-object v0, v1, v2
    const-string v0, "%.1f GB"
    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v0
    return-object v0

    :check_mb
    # Check >= 1MB (1048576)
    const-wide/32 v0, 0x100000
    cmp-long v2, p0, v0
    if-ltz v2, :check_kb

    long-to-double v0, p0
    const-wide v2, 0x4130000000000000L    # 1048576.0 as double
    div-double/2addr v0, v2
    invoke-static {v0, v1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;
    move-result-object v0
    const/4 v1, 0x1
    new-array v1, v1, [Ljava/lang/Object;
    const/4 v2, 0x0
    aput-object v0, v1, v2
    const-string v0, "%.1f MB"
    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v0
    return-object v0

    :check_kb
    # Check >= 1KB (1024)
    const-wide/16 v0, 0x400
    cmp-long v2, p0, v0
    if-ltz v2, :bytes

    long-to-double v0, p0
    const-wide v2, 0x4090000000000000L    # 1024.0 as double
    div-double/2addr v0, v2
    invoke-static {v0, v1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;
    move-result-object v0
    const/4 v1, 0x1
    new-array v1, v1, [Ljava/lang/Object;
    const/4 v2, 0x0
    aput-object v0, v1, v2
    const-string v0, "%.1f KB"
    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;
    move-result-object v0
    return-object v0

    :bytes
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, p0, p1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;
    const-string v1, " B"
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ===== HELPER: Format date from millis =====
.method public static formatDate(J)Ljava/lang/String;
    .locals 3

    new-instance v0, Ljava/text/SimpleDateFormat;
    const-string v1, "yyyy-MM-dd HH:mm"
    invoke-direct {v0, v1}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V
    new-instance v1, Ljava/util/Date;
    invoke-direct {v1, p0, p1}, Ljava/util/Date;-><init>(J)V
    invoke-virtual {v0, v1}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;
    move-result-object v0
    return-object v0
.end method


# ===== HELPER: Get file extension icon emoji =====
.method public static getFileIcon(Ljava/lang/String;Z)Ljava/lang/String;
    .locals 2

    # p0 = filename, p1 = isDirectory
    if-eqz p1, :not_dir
    const-string v0, "\ud83d\udcc1"
    return-object v0

    :not_dir
    # Check file extensions
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v0

    # Image files
    const-string v1, ".jpg"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :image
    const-string v1, ".png"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :image
    const-string v1, ".gif"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :image
    const-string v1, ".webp"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :image
    goto :check_video

    :image
    const-string v0, "\ud83d\uddbc\ufe0f"
    return-object v0

    :check_video
    const-string v1, ".mp4"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :video
    const-string v1, ".mkv"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :video
    const-string v1, ".avi"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :video
    goto :check_audio

    :video
    const-string v0, "\ud83c\udfac"
    return-object v0

    :check_audio
    const-string v1, ".mp3"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :audio
    const-string v1, ".wav"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :audio
    const-string v1, ".ogg"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :audio
    goto :check_text

    :audio
    const-string v0, "\ud83c\udfb5"
    return-object v0

    :check_text
    const-string v1, ".txt"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".log"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".json"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".xml"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".csv"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".html"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".css"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".js"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".smali"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".java"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".kt"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".py"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".sh"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".properties"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".cfg"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".yml"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    const-string v1, ".yaml"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :text
    goto :check_apk

    :text
    const-string v0, "\ud83d\udcdd"
    return-object v0

    :check_apk
    const-string v1, ".apk"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :apk
    goto :check_zip

    :apk
    const-string v0, "\ud83d\udce6"
    return-object v0

    :check_zip
    const-string v1, ".zip"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :zip
    const-string v1, ".tar"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :zip
    const-string v1, ".gz"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :zip
    const-string v1, ".7z"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :zip
    const-string v1, ".rar"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :zip
    goto :check_db

    :zip
    const-string v0, "\ud83d\uddc3\ufe0f"
    return-object v0

    :check_db
    const-string v1, ".db"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :db
    const-string v1, ".sqlite"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :db
    goto :check_so

    :db
    const-string v0, "\ud83d\uddc4\ufe0f"
    return-object v0

    :check_so
    const-string v1, ".so"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :binary
    const-string v1, ".dex"
    invoke-virtual {v0, v1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v1
    if-nez v1, :binary
    goto :default_icon

    :binary
    const-string v0, "\u2699\ufe0f"
    return-object v0

    :default_icon
    const-string v0, "\ud83d\udcc4"
    return-object v0
.end method


# ===== Navigate to a directory path =====
.method public navigateTo(Ljava/lang/String;)V
    .locals 14

    # Copy p1 into v13 to avoid register overflow (p1=v16 with .locals 15)
    move-object v13, p1

    # Store current path
    iput-object v13, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    # Update breadcrumb
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;
    invoke-virtual {v0, v13}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Scroll breadcrumb to end
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;
    new-instance v1, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;
    invoke-direct {v1, v0}, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;-><init>(Landroid/widget/HorizontalScrollView;)V
    invoke-virtual {v0, v1}, Landroid/view/View;->post(Ljava/lang/Runnable;)Z

    # Clear existing file list
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v0}, Landroid/widget/LinearLayout;->removeAllViews()V

    # List files
    :try_start
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v13}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v2

    if-nez v2, :has_files

    # Permission denied or empty
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addEmptyView()V

    # Update status
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;
    const-string v1, "Permission denied or empty directory"
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    goto :done

    :has_files
    # Sort: directories first, then alphabetical
    invoke-static {v2}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;
    move-result-object v3

    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$FileComparator;
    invoke-direct {v4}, Lin/startv/hotstar/FileExplorerActivity$FileComparator;-><init>()V
    invoke-static {v3, v4}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    # Count dirs and files
    const/4 v5, 0x0    # dir count
    const/4 v6, 0x0    # file count

    invoke-interface {v3}, Ljava/util/List;->size()I
    move-result v7

    # Add ".." parent directory entry if not at root
    const-string v8, "/"
    invoke-virtual {v13, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-nez v8, :skip_parent

    iget-object v8, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;
    if-eqz v8, :add_parent
    invoke-virtual {v13, v8}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v8
    if-nez v8, :skip_parent

    :add_parent
    new-instance v8, Ljava/io/File;
    invoke-direct {v8, v13}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v8}, Ljava/io/File;->getParent()Ljava/lang/String;
    move-result-object v8

    if-eqz v8, :skip_parent
    invoke-virtual {p0, v8}, Lin/startv/hotstar/FileExplorerActivity;->addParentItem(Ljava/lang/String;)V

    :skip_parent
    # Iterate files and add items
    const/4 v9, 0x0    # index
    :file_loop
    if-ge v9, v7, :loop_done

    invoke-interface {v3, v9}, Ljava/util/List;->get(I)Ljava/lang/Object;
    move-result-object v10
    check-cast v10, Ljava/io/File;

    invoke-virtual {v10}, Ljava/io/File;->isDirectory()Z
    move-result v11

    if-eqz v11, :is_file
    add-int/lit8 v5, v5, 0x1
    goto :add_item
    :is_file
    add-int/lit8 v6, v6, 0x1

    :add_item
    invoke-virtual {p0, v10, v11}, Lin/startv/hotstar/FileExplorerActivity;->addFileItem(Ljava/io/File;Z)V

    add-int/lit8 v9, v9, 0x1
    goto :file_loop

    :loop_done
    # Update status bar
    new-instance v10, Ljava/lang/StringBuilder;
    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v10, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v11, " folders, "
    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v10, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v11, " files"
    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v10

    iget-object v11, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;
    invoke-virtual {v11, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # If no items, show empty
    if-nez v7, :done
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addEmptyView()V

    :done
    :try_end
    .catchall {:try_start .. :try_end} :catch_block
    goto :finally

    :catch_block
    move-exception v0
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v1

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;
    new-instance v3, Ljava/lang/StringBuilder;
    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V
    const-string v4, "Error: "
    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :finally
    # Scroll file list to top
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;
    const/4 v1, 0x0
    invoke-virtual {v0, v1, v1}, Landroid/widget/ScrollView;->scrollTo(II)V

    return-void
.end method


# ===== Add empty directory view =====
.method public addEmptyView()V
    .locals 4

    new-instance v0, Landroid/widget/TextView;
    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    const-string v1, "\ud83d\udcc2 Empty directory\n\nNo files or folders here"
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const v1, -0x6d6d6e    # 0xFF929293 gray text
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V

    const/high16 v1, 0x41800000    # 16.0f
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    const/16 v1, 0x11    # center
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setGravity(I)V

    const/16 v1, 0x60    # 96px padding
    invoke-virtual {v0, v1, v1, v1, v1}, Landroid/view/View;->setPadding(IIII)V

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    return-void
.end method


# ===== Add ".." parent directory entry =====
.method public addParentItem(Ljava/lang/String;)V
    .locals 8

    # p1 = parent path string
    # Create horizontal row
    new-instance v0, Landroid/widget/LinearLayout;
    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v1, 0x0    # HORIZONTAL
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v1, 0x10    # center_vertical
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setGravity(I)V

    # Padding
    const/16 v1, 0x20    # 32px horizontal
    const/16 v2, 0x18    # 24px vertical
    invoke-virtual {v0, v1, v2, v1, v2}, Landroid/view/View;->setPadding(IIII)V

    # Background - slightly lighter for hover feel
    const v1, -0xe5dfd7    # 0xFF1A2029
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    # Icon
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\u2b06\ufe0f"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41c00000    # 24.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V
    # Icon right margin
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v5, -0x2
    const/4 v6, -0x2
    invoke-direct {v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/4 v5, 0x0
    const/16 v6, 0x18    # 24px right margin
    invoke-virtual {v4, v5, v5, v6, v5}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Text column
    new-instance v3, Landroid/widget/LinearLayout;
    invoke-direct {v3, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v4, 0x1    # VERTICAL
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->setOrientation(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v5, 0x0
    const/4 v6, -0x2
    const/high16 v7, 0x3f800000    # 1.0f weight
    invoke-direct {v4, v5, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # Name ".."
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, ".."
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v5, -0x1
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41800000    # 16.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    sget-object v5, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Subtitle "Go up"
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, "Parent directory"
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v5, -0x6d6d6e    # 0xFF929293
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41600000    # 14.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Click listener → navigate to parent
    new-instance v3, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;
    invoke-direct {v3, p0, p1}, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    invoke-virtual {v0, v3}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    # Divider
    invoke-virtual {p0, v0}, Lin/startv/hotstar/FileExplorerActivity;->addDividerAfter(Landroid/view/View;)V

    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v3, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    return-void
.end method


# ===== Add a single file/folder item row =====
.method public addFileItem(Ljava/io/File;Z)V
    .locals 10

    # p1 = File, p2 = isDirectory
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v0    # filename

    # Skip hidden files that start with "." optionally — show them all
    # Create horizontal row
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x0    # HORIZONTAL
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v2, 0x10    # center_vertical
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setGravity(I)V

    # Padding
    const/16 v2, 0x20    # 32px horizontal
    const/16 v3, 0x14    # 20px vertical
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V

    # Background with ripple-like touch feedback via selectable item bg
    # Use simple background color
    const v2, -0xe9e4de    # 0xFF161B22
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V

    # ===== Icon =====
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-static {v0, p2}, Lin/startv/hotstar/FileExplorerActivity;->getFileIcon(Ljava/lang/String;Z)Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41c00000    # 24.0f
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V

    # Icon layout params with right margin
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, -0x2
    const/4 v5, -0x2
    invoke-direct {v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/4 v4, 0x0
    const/16 v5, 0x18    # 24px right margin
    invoke-virtual {v3, v4, v4, v5, v4}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== Text column (name + details) =====
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x1    # VERTICAL
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v4, 0x0
    const/4 v5, -0x2
    const/high16 v6, 0x3f800000    # 1.0f weight
    invoke-direct {v3, v4, v5, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # File name
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v3, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v4, -0x1    # white
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v4, 0x41800000    # 16.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V

    # Bold for directories
    if-eqz p2, :not_bold
    sget-object v4, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    :not_bold

    # Ellipsize long names
    const/4 v4, 0x1    # single line
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setSingleLine(Z)V
    sget-object v4, Landroid/text/TextUtils$TruncateAt;->MIDDLE:Landroid/text/TextUtils$TruncateAt;
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== Details line: size + date =====
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    if-eqz p2, :show_file_size

    # Directory - show item count
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v5
    if-eqz v5, :no_count
    array-length v6, v5
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v6, " items"
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :add_date
    :no_count
    const-string v6, "Access denied"
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :add_date

    :show_file_size
    invoke-virtual {p1}, Ljava/io/File;->length()J
    move-result-wide v5
    invoke-static {v5, v6}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :add_date
    const-string v7, "  \u2022  "
    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {p1}, Ljava/io/File;->lastModified()J
    move-result-wide v7
    invoke-static {v7, v8}, Lin/startv/hotstar/FileExplorerActivity;->formatDate(J)Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v4, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const v4, -0x6d6d6e    # 0xFF929293 gray
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v4, 0x41600000    # 14.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setSingleLine(Z)V

    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== Chevron for directories =====
    if-eqz p2, :no_chevron
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\u203a"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v4, -0x6d6d6e
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v4, 0x41c00000    # 24.0f
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v4, 0x10
    const/4 v5, 0x0
    invoke-virtual {v3, v4, v5, v5, v5}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    :no_chevron

    # ===== Click listener =====
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;
    move-result-object v3

    if-eqz p2, :file_click
    # Directory click — navigate
    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;
    invoke-direct {v4, p0, v3}, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    invoke-virtual {v1, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    goto :after_click

    :file_click
    # File click — open viewer
    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;
    invoke-direct {v4, p0, v3}, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V
    invoke-virtual {v1, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    # Long click — show options (copy path, delete, etc)
    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;
    invoke-direct {v4, p0, v3, v0}, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {v1, v4}, Landroid/view/View;->setOnLongClickListener(Landroid/view/View$OnLongClickListener;)V

    :after_click
    # Also add long click for directories
    if-eqz p2, :skip_dir_longclick
    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;
    invoke-direct {v4, p0, v3, v0}, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V
    invoke-virtual {v1, v4}, Landroid/view/View;->setOnLongClickListener(Landroid/view/View$OnLongClickListener;)V
    :skip_dir_longclick

    # Add thin divider line
    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->addDividerAfter(Landroid/view/View;)V

    iget-object v4, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v4, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    return-void
.end method


# ===== Helper: Add a thin divider line inside a parent view's bottom =====
.method public addDividerAfter(Landroid/view/View;)V
    .locals 0
    # We'll add dividers separately in the list
    return-void
.end method


# ===== onCreate =====
.method public onCreate(Landroid/os/Bundle;)V
    .locals 12

    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # ===== Root layout =====
    new-instance v0, Landroid/widget/LinearLayout;
    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v1, 0x1    # VERTICAL
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v1, -0xe9e4de    # 0xFF161B22 dark bg
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    # ===== TOOLBAR AREA =====
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x0    # HORIZONTAL
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v2, 0x10    # center_vertical
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setGravity(I)V

    # Toolbar background
    new-instance v2, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v2}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v3, -0xeae5df    # 0xFF151A21
    invoke-virtual {v2, v3}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # Padding
    const/16 v2, 0x18    # 24px
    const/16 v3, 0x14    # 20px
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V

    # Bottom border (just use elevation shadow effect through a divider below)

    # Back button (←)
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, "\u2190"
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v5, -0x1
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41c00000    # 24.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v5, 0x0
    const/16 v6, 0x0
    const/16 v7, 0x20
    invoke-virtual {v4, v5, v6, v7, v6}, Landroid/view/View;->setPadding(IIII)V

    # Back button click → finish activity
    new-instance v5, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;
    invoke-direct {v5, p0}, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V
    invoke-virtual {v4, v5}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Title
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, "\ud83d\udcc1 File Explorer"
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v5, -0x1
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41900000    # 18.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    sget-object v5, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    # Weight fill
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, 0x0
    const/4 v7, -0x2
    const/high16 v8, 0x3f800000    # 1.0f
    invoke-direct {v5, v6, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v4, v5}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Home button (🏠)
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, "\ud83c\udfe0"
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v5, 0x41c00000    # 24.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v5, 0x10    # right pad
    const/16 v6, 0x0
    invoke-virtual {v4, v5, v6, v5, v6}, Landroid/view/View;->setPadding(IIII)V
    new-instance v5, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;
    invoke-direct {v5, p0}, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V
    invoke-virtual {v4, v5}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # SD card / root button
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v5, "\ud83d\udcbe"
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v5, 0x41c00000
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v5, 0x10
    const/16 v6, 0x0
    invoke-virtual {v4, v5, v6, v5, v6}, Landroid/view/View;->setPadding(IIII)V
    new-instance v5, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;
    invoke-direct {v5, p0}, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V
    invoke-virtual {v4, v5}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== Toolbar divider =====
    new-instance v1, Landroid/view/View;
    invoke-direct {v1, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1
    const/4 v4, 0x1
    invoke-direct {v2, v3, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v2, -0xcfc9c3    # 0xFF30363D
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== BREADCRUMB BAR =====
    new-instance v1, Landroid/widget/HorizontalScrollView;
    invoke-direct {v1, p0}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V
    iput-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;
    const v2, -0xebe6e0    # 0xFF14191F slightly darker
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    const/16 v2, 0x10    # 16px padding
    const/16 v3, 0xc     # 12px vertical
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V
    # No scroll bar
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setHorizontalScrollBarEnabled(Z)V

    # Breadcrumb text (monospace)
    new-instance v4, Landroid/widget/TextView;
    invoke-direct {v4, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v4, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;
    const v5, -0x1e96    # 0xFFFFE16A warm yellow
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v5, 0x41700000    # 15.0f
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V
    sget-object v5, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/4 v5, 0x1
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setSingleLine(Z)V
    invoke-virtual {v1, v4}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== Breadcrumb divider =====
    new-instance v1, Landroid/view/View;
    invoke-direct {v1, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1
    const/4 v4, 0x1
    invoke-direct {v2, v3, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v2, -0xcfc9c3
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== FILE LIST SCROLLVIEW =====
    new-instance v1, Landroid/widget/ScrollView;
    invoke-direct {v1, p0}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    iput-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    # Always-visible scrollbar
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V
    const/4 v2, 0x0
    invoke-virtual {v1, v2}, Landroid/view/View;->setScrollbarFadingEnabled(Z)V

    # Fill remaining space
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1    # MATCH_PARENT
    const/4 v4, 0x0     # 0 height
    const/high16 v5, 0x3f800000    # 1.0f weight
    invoke-direct {v2, v3, v4, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v1, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # Inner LinearLayout for file items
    new-instance v6, Landroid/widget/LinearLayout;
    invoke-direct {v6, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v7, 0x1
    invoke-virtual {v6, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v6, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v1, v6}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== STATUS BAR divider =====
    new-instance v1, Landroid/view/View;
    invoke-direct {v1, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1
    const/4 v4, 0x1
    invoke-direct {v2, v3, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v1, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v2, -0xcfc9c3
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ===== STATUS BAR =====
    new-instance v1, Landroid/widget/TextView;
    invoke-direct {v1, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;
    const-string v2, "Loading..."
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v2, -0x6d6d6e    # gray
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setTextColor(I)V
    const/high16 v2, 0x41600000    # 14.0f
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setTextSize(F)V
    sget-object v2, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const v2, -0xebe6e0
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V
    const/16 v2, 0x18    # 24px
    const/16 v3, 0xc     # 12px
    invoke-virtual {v1, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Set content view
    invoke-virtual {p0, v0}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    # Determine start path from intent or default to app data dir
    invoke-virtual {p0}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;
    move-result-object v1
    const-string v2, "path"
    invoke-virtual {v1, v2}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3

    if-nez v3, :has_path
    # Default to app data dir
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;
    move-result-object v4
    iget-object v3, v4, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;
    :has_path

    iput-object v3, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;

    # Navigate to start path
    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    return-void
.end method


# ===== Handle back press — navigate up or finish =====
.method public onBackPressed()V
    .locals 3

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;
    const-string v1, "/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :finish_activity

    # Check if we're at rootPath
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;
    if-eqz v1, :go_up
    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v2
    if-nez v2, :finish_activity

    :go_up
    new-instance v1, Ljava/io/File;
    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v1}, Ljava/io/File;->getParent()Ljava/lang/String;
    move-result-object v2

    if-eqz v2, :finish_activity
    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V
    return-void

    :finish_activity
    invoke-virtual {p0}, Landroid/app/Activity;->finish()V
    return-void
.end method
