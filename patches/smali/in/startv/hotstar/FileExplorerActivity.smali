.class public Lin/startv/hotstar/FileExplorerActivity;
.super Landroid/app/Activity;
.source "FileExplorerActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;,
        Lin/startv/hotstar/FileExplorerActivity$FileComparator;,
        Lin/startv/hotstar/FileExplorerActivity$NavClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$FileClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$BackClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;,
        Lin/startv/hotstar/FileExplorerActivity$DeleteConfirmListener;,
        Lin/startv/hotstar/FileExplorerActivity$LongClickMenuListener;
    }
.end annotation


# static fields
.field public static final C_ACCENT:I = -0xbb7501

.field public static final C_ACCENT_GREEN:I = -0xff198a

.field public static final C_BG_BREADCRUMB:I = -0xe5e5e6

.field public static final C_BG_ITEM:I = -0xe1e1e2

.field public static final C_BG_ITEM_ALT:I = -0xdbdbdc

.field public static final C_BG_MAIN:I = -0xededee

.field public static final C_BG_STATUS:I = -0xe5e5e6

.field public static final C_BG_TOOLBAR:I = -0xe1e1e2

.field public static final C_DIVIDER:I = -0xd3d3d4

.field public static final C_FAB:I = -0xbb7501

.field public static final C_ICON_FILE:I = -0x6f5b52

.field public static final C_ICON_FOLDER:I = -0x35d8

.field public static final C_TEXT_PATH:I = -0x9b4a0a

.field public static final C_TEXT_PRIMARY:I = -0x1f1f20

.field public static final C_TEXT_SECONDARY:I = -0x777778


# instance fields
.field public breadcrumbLayout:Landroid/widget/HorizontalScrollView;

.field public breadcrumbText:Landroid/widget/TextView;

.field public currentPath:Ljava/lang/String;

.field public fileListLayout:Landroid/widget/LinearLayout;

.field public fileListScroll:Landroid/widget/ScrollView;

.field public itemIndex:I

.field public rootPath:Ljava/lang/String;

.field public statusText:Landroid/widget/TextView;


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 44
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    .line 71
    const/4 v0, 0x0

    iput v0, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    return-void
.end method

.method public static formatDate(J)Ljava/lang/String;
    .locals 2

    .line 88
    new-instance v0, Ljava/text/SimpleDateFormat;

    const-string v1, "yyyy-MM-dd HH:mm"

    invoke-direct {v0, v1}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;)V

    .line 89
    new-instance v1, Ljava/util/Date;

    invoke-direct {v1, p0, p1}, Ljava/util/Date;-><init>(J)V

    invoke-virtual {v0, v1}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public static formatSize(J)Ljava/lang/String;
    .locals 5

    .line 75
    const-wide/32 v0, 0x40000000

    const/4 v2, 0x0

    const/4 v3, 0x1

    cmp-long v4, p0, v0

    if-ltz v4, :cond_0

    .line 76
    long-to-double p0, p0

    const-wide/high16 v0, 0x41d0000000000000L    # 1.073741824E9

    invoke-static {p0, p1}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr p0, v0

    invoke-static {p0, p1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object p0

    new-array p1, v3, [Ljava/lang/Object;

    aput-object p0, p1, v2

    const-string p0, "%.1f GB"

    invoke-static {p0, p1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 77
    :cond_0
    const-wide/32 v0, 0x100000

    cmp-long v4, p0, v0

    if-ltz v4, :cond_1

    .line 78
    long-to-double p0, p0

    const-wide/high16 v0, 0x4130000000000000L    # 1048576.0

    invoke-static {p0, p1}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr p0, v0

    invoke-static {p0, p1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object p0

    new-array p1, v3, [Ljava/lang/Object;

    aput-object p0, p1, v2

    const-string p0, "%.1f MB"

    invoke-static {p0, p1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 79
    :cond_1
    const-wide/16 v0, 0x400

    cmp-long v4, p0, v0

    if-ltz v4, :cond_2

    .line 80
    long-to-double p0, p0

    const-wide/high16 v0, 0x4090000000000000L    # 1024.0

    invoke-static {p0, p1}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr p0, v0

    invoke-static {p0, p1}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object p0

    new-array p1, v3, [Ljava/lang/Object;

    aput-object p0, p1, v2

    const-string p0, "%.1f KB"

    invoke-static {p0, p1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 82
    :cond_2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p0, p1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string p1, " B"

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public static getFileIcon(Ljava/lang/String;Z)Ljava/lang/String;
    .locals 0

    .line 94
    if-eqz p1, :cond_0

    const-string p0, "\ud83d\udcc1"

    return-object p0

    .line 96
    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p0

    .line 99
    const-string p1, ".jpg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_11

    const-string p1, ".png"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_11

    const-string p1, ".gif"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_11

    .line 100
    const-string p1, ".webp"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_11

    const-string p1, ".svg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_11

    const-string p1, ".bmp"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_1

    goto/16 :goto_7

    .line 104
    :cond_1
    const-string p1, ".mp4"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_10

    const-string p1, ".mkv"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_10

    const-string p1, ".avi"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_10

    .line 105
    const-string p1, ".mov"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_10

    const-string p1, ".webm"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_10

    const-string p1, ".flv"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_2

    goto/16 :goto_6

    .line 109
    :cond_2
    const-string p1, ".mp3"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    const-string p1, ".wav"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    const-string p1, ".ogg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    .line 110
    const-string p1, ".flac"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    const-string p1, ".aac"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_f

    const-string p1, ".m4a"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_3

    goto/16 :goto_5

    .line 114
    :cond_3
    const-string p1, ".txt"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".log"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".json"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 115
    const-string p1, ".xml"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".csv"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".html"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 116
    const-string p1, ".css"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".js"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".smali"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 117
    const-string p1, ".java"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".kt"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".py"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 118
    const-string p1, ".sh"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".properties"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".cfg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 119
    const-string p1, ".yml"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".yaml"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".md"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    .line 120
    const-string p1, ".gradle"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".ini"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_e

    const-string p1, ".conf"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_4

    goto/16 :goto_4

    .line 124
    :cond_4
    const-string p1, ".apk"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_d

    const-string p1, ".xapk"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_d

    const-string p1, ".apks"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_5

    goto/16 :goto_3

    .line 128
    :cond_5
    const-string p1, ".zip"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    const-string p1, ".tar"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    const-string p1, ".gz"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    .line 129
    const-string p1, ".7z"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    const-string p1, ".rar"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    const-string p1, ".bz2"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_c

    .line 130
    const-string p1, ".xz"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_6

    goto :goto_2

    .line 134
    :cond_6
    const-string p1, ".db"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    const-string p1, ".sqlite"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    const-string p1, ".sqlite3"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_7

    goto :goto_1

    .line 138
    :cond_7
    const-string p1, ".so"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    const-string p1, ".dex"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    const-string p1, ".odex"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    .line 139
    const-string p1, ".oat"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    const-string p1, ".vdex"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_8

    goto :goto_0

    .line 143
    :cond_8
    const-string p1, ".pdf"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    const-string p1, "\ud83d\udcc4"

    if-eqz p0, :cond_9

    .line 144
    return-object p1

    .line 147
    :cond_9
    return-object p1

    .line 140
    :cond_a
    :goto_0
    const-string p0, "\u2699\ufe0f"

    return-object p0

    .line 135
    :cond_b
    :goto_1
    const-string p0, "\ud83d\uddc4\ufe0f"

    return-object p0

    .line 131
    :cond_c
    :goto_2
    const-string p0, "\ud83d\uddc3\ufe0f"

    return-object p0

    .line 125
    :cond_d
    :goto_3
    const-string p0, "\ud83d\udce6"

    return-object p0

    .line 121
    :cond_e
    :goto_4
    const-string p0, "\ud83d\udcdd"

    return-object p0

    .line 111
    :cond_f
    :goto_5
    const-string p0, "\ud83c\udfb5"

    return-object p0

    .line 106
    :cond_10
    :goto_6
    const-string p0, "\ud83c\udfac"

    return-object p0

    .line 101
    :cond_11
    :goto_7
    const-string p0, "\ud83d\uddbc\ufe0f"

    return-object p0
.end method

.method public static getIconColor(Ljava/lang/String;Z)I
    .locals 0

    .line 152
    if-eqz p1, :cond_0

    const/16 p0, -0x35d8

    return p0

    .line 154
    :cond_0
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object p0

    .line 155
    const-string p1, ".jpg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    const-string p1, ".png"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    const-string p1, ".gif"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    .line 156
    const-string p1, ".webp"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_b

    const-string p1, ".svg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_1

    goto/16 :goto_4

    .line 159
    :cond_1
    const-string p1, ".mp4"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    const-string p1, ".mkv"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_a

    const-string p1, ".avi"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_2

    goto/16 :goto_3

    .line 162
    :cond_2
    const-string p1, ".mp3"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_9

    const-string p1, ".wav"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_9

    const-string p1, ".ogg"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_3

    goto :goto_2

    .line 165
    :cond_3
    const-string p1, ".txt"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_8

    const-string p1, ".log"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_8

    const-string p1, ".json"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_8

    .line 166
    const-string p1, ".xml"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_8

    const-string p1, ".smali"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_8

    const-string p1, ".java"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_4

    goto :goto_1

    .line 169
    :cond_4
    const-string p1, ".apk"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-eqz p1, :cond_5

    .line 170
    const p0, -0xd95966

    return p0

    .line 172
    :cond_5
    const-string p1, ".zip"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_7

    const-string p1, ".tar"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p1

    if-nez p1, :cond_7

    const-string p1, ".gz"

    invoke-virtual {p0, p1}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result p0

    if-eqz p0, :cond_6

    goto :goto_0

    .line 175
    :cond_6
    const p0, -0x876f64

    return p0

    .line 173
    :cond_7
    :goto_0
    const p0, -0x8fbd

    return p0

    .line 167
    :cond_8
    :goto_1
    const p0, -0xbd5a0b

    return p0

    .line 163
    :cond_9
    :goto_2
    const p0, -0x54b844

    return p0

    .line 160
    :cond_a
    :goto_3
    const p0, -0x10acb0

    return p0

    .line 157
    :cond_b
    :goto_4
    const p0, -0x994496

    return p0
.end method


# virtual methods
.method public addDivider()V
    .locals 4

    .line 483
    new-instance v0, Landroid/view/View;

    invoke-direct {v0, p0}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 484
    new-instance v1, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v2, -0x1

    const/4 v3, 0x1

    invoke-direct {v1, v2, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 486
    const/16 v2, 0x44

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    const/4 v3, 0x0

    invoke-virtual {v1, v2, v3, v3, v3}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 487
    invoke-virtual {v0, v1}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 488
    const v1, -0xd3d3d4

    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    .line 489
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 490
    return-void
.end method

.method public addDividerAfter(Landroid/view/View;)V
    .locals 0

    .line 495
    return-void
.end method

.method public addEmptyView()V
    .locals 6

    .line 282
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 283
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 284
    const/16 v1, 0x11

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 285
    const/16 v2, 0x20

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    const/16 v4, 0x40

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v0, v3, v5, v2, v4}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 287
    new-instance v2, Landroid/widget/TextView;

    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 288
    const-string v3, "\ud83d\udcc2"

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 289
    const/high16 v3, 0x42400000    # 48.0f

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V

    .line 290
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setGravity(I)V

    .line 291
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 293
    new-instance v2, Landroid/widget/TextView;

    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 294
    const-string v3, "Empty directory"

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 295
    const v3, -0x777778

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V

    .line 296
    const/high16 v3, 0x41800000    # 16.0f

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V

    .line 297
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setGravity(I)V

    .line 298
    const/16 v3, 0xc

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    const/4 v4, 0x0

    invoke-virtual {v2, v4, v3, v4, v4}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 299
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 301
    new-instance v2, Landroid/widget/TextView;

    invoke-direct {v2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 302
    const-string v3, "No files or folders here"

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 303
    const v3, -0xaaaaab

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V

    .line 304
    const/high16 v3, 0x41500000    # 13.0f

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V

    .line 305
    invoke-virtual {v2, v1}, Landroid/widget/TextView;->setGravity(I)V

    .line 306
    const/4 v1, 0x4

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v1

    invoke-virtual {v2, v4, v1, v4, v4}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 307
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 309
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 310
    return-void
.end method

.method public addFileItem(Ljava/io/File;Z)V
    .locals 8

    .line 362
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v0

    .line 363
    iget v1, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    rem-int/lit8 v1, v1, 0x2

    const/4 v2, 0x0

    const/4 v3, 0x1

    if-ne v1, v3, :cond_0

    const/4 v1, 0x1

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    .line 364
    :goto_0
    iget v4, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    add-int/2addr v4, v3

    iput v4, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    .line 366
    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->createItemRow(Z)Landroid/widget/LinearLayout;

    move-result-object v1

    .line 369
    invoke-static {v0, p2}, Lin/startv/hotstar/FileExplorerActivity;->getFileIcon(Ljava/lang/String;Z)Ljava/lang/String;

    move-result-object v4

    .line 370
    invoke-static {v0, p2}, Lin/startv/hotstar/FileExplorerActivity;->getIconColor(Ljava/lang/String;Z)I

    move-result v5

    .line 371
    invoke-virtual {p0, v4, v5}, Lin/startv/hotstar/FileExplorerActivity;->createIconCircle(Ljava/lang/String;I)Landroid/widget/LinearLayout;

    move-result-object v4

    .line 372
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 375
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 376
    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 377
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v6, -0x2

    const/high16 v7, 0x3f800000    # 1.0f

    invoke-direct {v5, v2, v6, v7}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 378
    const/16 v6, 0xc

    invoke-virtual {p0, v6}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v6

    invoke-virtual {v5, v6, v2, v2, v2}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 379
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 382
    new-instance v5, Landroid/widget/TextView;

    invoke-direct {v5, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 383
    invoke-virtual {v5, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 384
    const v6, -0x1f1f20

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setTextColor(I)V

    .line 385
    const/high16 v6, 0x41700000    # 15.0f

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setTextSize(F)V

    .line 386
    invoke-virtual {v5, v3}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 387
    sget-object v6, Landroid/text/TextUtils$TruncateAt;->MIDDLE:Landroid/text/TextUtils$TruncateAt;

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    .line 388
    if-eqz p2, :cond_1

    .line 389
    sget-object v6, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v5, v6}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 391
    :cond_1
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 394
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    .line 395
    if-eqz p2, :cond_3

    .line 396
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v6

    .line 397
    if-eqz v6, :cond_2

    .line 398
    array-length v6, v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " items"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_1

    .line 400
    :cond_2
    const-string v6, "Access denied"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 402
    :goto_1
    goto :goto_2

    .line 403
    :cond_3
    invoke-virtual {p1}, Ljava/io/File;->length()J

    move-result-wide v6

    invoke-static {v6, v7}, Lin/startv/hotstar/FileExplorerActivity;->formatSize(J)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 405
    :goto_2
    const-string v6, "  \u2022  "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 406
    invoke-virtual {p1}, Ljava/io/File;->lastModified()J

    move-result-wide v6

    invoke-static {v6, v7}, Lin/startv/hotstar/FileExplorerActivity;->formatDate(J)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 408
    new-instance v6, Landroid/widget/TextView;

    invoke-direct {v6, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 409
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v6, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 410
    const v5, -0x777778

    invoke-virtual {v6, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 411
    const/high16 v7, 0x41400000    # 12.0f

    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setTextSize(F)V

    .line 412
    invoke-virtual {v6, v3}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 413
    invoke-virtual {v4, v6}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 415
    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 418
    if-eqz p2, :cond_4

    .line 419
    new-instance v3, Landroid/widget/TextView;

    invoke-direct {v3, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 420
    const-string v4, "\u203a"

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 421
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 422
    const/high16 v4, 0x41c00000    # 24.0f

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextSize(F)V

    .line 423
    const/16 v4, 0x8

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v3, v4, v2, v2, v2}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 424
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 428
    :cond_4
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object p1

    .line 429
    if-eqz p2, :cond_5

    .line 430
    new-instance p2, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;

    invoke-direct {p2, p0, p0, p1}, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V

    invoke-virtual {v1, p2}, Landroid/widget/LinearLayout;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    goto :goto_3

    .line 432
    :cond_5
    new-instance p2, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;

    invoke-direct {p2, p0, p0, p1}, Lin/startv/hotstar/FileExplorerActivity$FileClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V

    invoke-virtual {v1, p2}, Landroid/widget/LinearLayout;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 436
    :goto_3
    new-instance p2, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;

    invoke-direct {p2, p0, p0, p1, v0}, Lin/startv/hotstar/FileExplorerActivity$FileLongClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v1, p2}, Landroid/widget/LinearLayout;->setOnLongClickListener(Landroid/view/View$OnLongClickListener;)V

    .line 438
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {p1, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 439
    iget p1, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    invoke-virtual {p0, v1, p1}, Lin/startv/hotstar/FileExplorerActivity;->animateItemEntrance(Landroid/view/View;I)V

    .line 442
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addDivider()V

    .line 443
    return-void
.end method

.method public addParentItem(Ljava/lang/String;)V
    .locals 6

    .line 314
    const/4 v0, 0x1

    invoke-virtual {p0, v0}, Lin/startv/hotstar/FileExplorerActivity;->createItemRow(Z)Landroid/widget/LinearLayout;

    move-result-object v1

    .line 317
    const-string v2, "\u2b06\ufe0f"

    const v3, -0xa39440

    invoke-virtual {p0, v2, v3}, Lin/startv/hotstar/FileExplorerActivity;->createIconCircle(Ljava/lang/String;I)Landroid/widget/LinearLayout;

    move-result-object v2

    .line 318
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 321
    new-instance v2, Landroid/widget/LinearLayout;

    invoke-direct {v2, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 322
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 323
    new-instance v0, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v3, -0x2

    const/high16 v4, 0x3f800000    # 1.0f

    const/4 v5, 0x0

    invoke-direct {v0, v5, v3, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 324
    const/16 v3, 0xc

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {v0, v3, v5, v5, v5}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 325
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 327
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 328
    const-string v3, ".."

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 329
    const v3, -0x1f1f20

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setTextColor(I)V

    .line 330
    const/high16 v3, 0x41700000    # 15.0f

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setTextSize(F)V

    .line 331
    sget-object v3, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 332
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 334
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 335
    const-string v3, "Parent directory"

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 336
    const v3, -0x777778

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setTextColor(I)V

    .line 337
    const/high16 v4, 0x41400000    # 12.0f

    invoke-virtual {v0, v4}, Landroid/widget/TextView;->setTextSize(F)V

    .line 338
    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 340
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 343
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 344
    const-string v2, "\u203a"

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 345
    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setTextColor(I)V

    .line 346
    const/high16 v2, 0x41c00000    # 24.0f

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 347
    const/16 v2, 0x8

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    invoke-virtual {v0, v2, v5, v5, v5}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 348
    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 351
    new-instance v0, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;

    invoke-direct {v0, p0, p0, p1}, Lin/startv/hotstar/FileExplorerActivity$NavClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Landroid/widget/LinearLayout;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 353
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {p1, v1}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 354
    invoke-virtual {p0, v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->animateItemEntrance(Landroid/view/View;I)V

    .line 357
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addDivider()V

    .line 358
    return-void
.end method

.method public animateItemEntrance(Landroid/view/View;I)V
    .locals 4

    .line 181
    mul-int/lit8 p2, p2, 0x1e

    const/16 v0, 0x190

    :try_start_0
    invoke-static {p2, v0}, Ljava/lang/Math;->min(II)I

    move-result p2

    .line 182
    new-instance v0, Landroid/view/animation/AlphaAnimation;

    const/high16 v1, 0x3f800000    # 1.0f

    const/4 v2, 0x0

    invoke-direct {v0, v2, v1}, Landroid/view/animation/AlphaAnimation;-><init>(FF)V

    .line 183
    new-instance v1, Landroid/view/animation/TranslateAnimation;

    const/16 v3, 0x14

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    int-to-float v3, v3

    invoke-direct {v1, v2, v2, v3, v2}, Landroid/view/animation/TranslateAnimation;-><init>(FFFF)V

    .line 184
    new-instance v2, Landroid/view/animation/AnimationSet;

    const/4 v3, 0x1

    invoke-direct {v2, v3}, Landroid/view/animation/AnimationSet;-><init>(Z)V

    .line 185
    invoke-virtual {v2, v0}, Landroid/view/animation/AnimationSet;->addAnimation(Landroid/view/animation/Animation;)V

    .line 186
    invoke-virtual {v2, v1}, Landroid/view/animation/AnimationSet;->addAnimation(Landroid/view/animation/Animation;)V

    .line 187
    const-wide/16 v0, 0xfa

    invoke-virtual {v2, v0, v1}, Landroid/view/animation/AnimationSet;->setDuration(J)V

    .line 188
    int-to-long v0, p2

    invoke-virtual {v2, v0, v1}, Landroid/view/animation/AnimationSet;->setStartOffset(J)V

    .line 189
    new-instance p2, Landroid/view/animation/DecelerateInterpolator;

    invoke-direct {p2}, Landroid/view/animation/DecelerateInterpolator;-><init>()V

    invoke-virtual {v2, p2}, Landroid/view/animation/AnimationSet;->setInterpolator(Landroid/view/animation/Interpolator;)V

    .line 190
    invoke-virtual {p1, v2}, Landroid/view/View;->startAnimation(Landroid/view/animation/Animation;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 193
    goto :goto_0

    .line 191
    :catch_0
    move-exception p1

    .line 194
    :goto_0
    return-void
.end method

.method public createIconCircle(Ljava/lang/String;I)Landroid/widget/LinearLayout;
    .locals 4

    .line 461
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 462
    const/16 v1, 0x11

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 463
    const/16 v2, 0x28

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    .line 464
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v3, v2, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 465
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 467
    new-instance v2, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v2}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 468
    const/4 v3, 0x1

    invoke-virtual {v2, v3}, Landroid/graphics/drawable/GradientDrawable;->setShape(I)V

    .line 469
    const v3, 0xffffff

    and-int/2addr p2, v3

    const/high16 v3, 0x26000000

    or-int/2addr p2, v3

    invoke-virtual {v2, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 470
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 472
    new-instance p2, Landroid/widget/TextView;

    invoke-direct {p2, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 473
    invoke-virtual {p2, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 474
    const/high16 p1, 0x41a00000    # 20.0f

    invoke-virtual {p2, p1}, Landroid/widget/TextView;->setTextSize(F)V

    .line 475
    invoke-virtual {p2, v1}, Landroid/widget/TextView;->setGravity(I)V

    .line 476
    invoke-virtual {v0, p2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 478
    return-object v0
.end method

.method public createItemRow(Z)Landroid/widget/LinearLayout;
    .locals 5

    .line 447
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 448
    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 449
    const/16 v1, 0x10

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 450
    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    const/16 v3, 0xc

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v1

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {v0, v2, v4, v1, v3}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 452
    new-instance v1, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v1}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 453
    if-eqz p1, :cond_0

    const p1, -0xdbdbdc

    goto :goto_0

    :cond_0
    const p1, -0xe1e1e2

    :goto_0
    invoke-virtual {v1, p1}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 454
    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 456
    return-object v0
.end method

.method public dpToPx(I)I
    .locals 1

    .line 198
    int-to-float p1, p1

    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v0

    iget v0, v0, Landroid/util/DisplayMetrics;->density:F

    mul-float p1, p1, v0

    const/high16 v0, 0x3f000000    # 0.5f

    add-float/2addr p1, v0

    float-to-int p1, p1

    return p1
.end method

.method public navigateTo(Ljava/lang/String;)V
    .locals 6

    .line 203
    iput-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    .line 204
    const/4 v0, 0x0

    iput v0, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    .line 207
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    if-eqz v1, :cond_0

    .line 208
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    invoke-virtual {v1, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 212
    :cond_0
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    if-eqz v1, :cond_1

    .line 213
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    new-instance v2, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;

    iget-object v3, p0, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    invoke-direct {v2, p0, v3}, Lin/startv/hotstar/FileExplorerActivity$ScrollEndRunnable;-><init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/HorizontalScrollView;)V

    invoke-virtual {v1, v2}, Landroid/widget/HorizontalScrollView;->post(Ljava/lang/Runnable;)Z

    .line 217
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    if-eqz v1, :cond_2

    .line 218
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v1}, Landroid/widget/LinearLayout;->removeAllViews()V

    .line 222
    :cond_2
    :try_start_0
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 223
    invoke-virtual {v1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object v1

    .line 225
    if-nez v1, :cond_4

    .line 226
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addEmptyView()V

    .line 227
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    if-eqz p1, :cond_3

    .line 228
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    const-string v1, "Permission denied or empty directory"

    invoke-virtual {p1, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 230
    :cond_3
    return-void

    .line 234
    :cond_4
    invoke-static {v1}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v1

    .line 235
    new-instance v2, Lin/startv/hotstar/FileExplorerActivity$FileComparator;

    invoke-direct {v2}, Lin/startv/hotstar/FileExplorerActivity$FileComparator;-><init>()V

    invoke-static {v1, v2}, Ljava/util/Collections;->sort(Ljava/util/List;Ljava/util/Comparator;)V

    .line 237
    nop

    .line 238
    nop

    .line 241
    const-string v2, "/"

    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_6

    .line 242
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;

    if-eqz v2, :cond_5

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_6

    .line 243
    :cond_5
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 244
    invoke-virtual {v2}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object p1

    .line 245
    if-eqz p1, :cond_6

    .line 246
    invoke-virtual {p0, p1}, Lin/startv/hotstar/FileExplorerActivity;->addParentItem(Ljava/lang/String;)V

    .line 252
    :cond_6
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    const/4 v2, 0x0

    const/4 v3, 0x0

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_8

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/io/File;

    .line 253
    invoke-virtual {v4}, Ljava/io/File;->isDirectory()Z

    move-result v5

    .line 254
    if-eqz v5, :cond_7

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 255
    :cond_7
    add-int/lit8 v3, v3, 0x1

    .line 256
    :goto_1
    invoke-virtual {p0, v4, v5}, Lin/startv/hotstar/FileExplorerActivity;->addFileItem(Ljava/io/File;Z)V

    .line 257
    goto :goto_0

    .line 260
    :cond_8
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    if-eqz p1, :cond_9

    .line 261
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v4, " folders, "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " files"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 264
    :cond_9
    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result p1

    if-eqz p1, :cond_a

    .line 265
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addEmptyView()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 272
    :cond_a
    goto :goto_2

    .line 268
    :catch_0
    move-exception p1

    .line 269
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    if-eqz v1, :cond_b

    .line 270
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Error: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v1, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 275
    :cond_b
    :goto_2
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    if-eqz p1, :cond_c

    .line 276
    iget-object p1, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    invoke-virtual {p1, v0, v0}, Landroid/widget/ScrollView;->scrollTo(II)V

    .line 278
    :cond_c
    return-void
.end method

.method public onBackPressed()V
    .locals 2

    .line 883
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    if-eqz v0, :cond_3

    const-string v0, "/"

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_1

    .line 887
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 888
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->finish()V

    .line 889
    return-void

    .line 892
    :cond_1
    new-instance v0, Ljava/io/File;

    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-direct {v0, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 893
    invoke-virtual {v0}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object v0

    .line 894
    if-eqz v0, :cond_2

    .line 895
    invoke-virtual {p0, v0}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V

    goto :goto_0

    .line 897
    :cond_2
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->finish()V

    .line 899
    :goto_0
    return-void

    .line 884
    :cond_3
    :goto_1
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->finish()V

    .line 885
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 16

    .line 500
    move-object/from16 v1, p0

    const-string v2, "HSPatch"

    invoke-super/range {p0 .. p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 505
    const/4 v3, 0x1

    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const v4, -0xe1e1e2

    const/16 v5, 0x15

    if-lt v0, v5, :cond_0

    .line 506
    invoke-virtual {v1}, Lin/startv/hotstar/FileExplorerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/view/Window;->setStatusBarColor(I)V

    .line 508
    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v6, 0x1c

    const v7, -0xededee

    if-lt v0, v6, :cond_1

    .line 509
    invoke-virtual {v1}, Lin/startv/hotstar/FileExplorerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v7}, Landroid/view/Window;->setNavigationBarColor(I)V

    .line 513
    :cond_1
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 514
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 515
    invoke-virtual {v0, v7}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 518
    new-instance v6, Landroid/widget/LinearLayout;

    invoke-direct {v6, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 519
    const/4 v7, 0x0

    invoke-virtual {v6, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 520
    const/16 v8, 0x10

    invoke-virtual {v6, v8}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 521
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 522
    const/16 v4, 0xc

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v6, v9, v10, v11, v12}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 525
    sget v9, Landroid/os/Build$VERSION;->SDK_INT:I

    const/4 v10, 0x4

    if-lt v9, v5, :cond_2

    .line 526
    invoke-virtual {v1, v10}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    int-to-float v5, v5

    invoke-virtual {v6, v5}, Landroid/widget/LinearLayout;->setElevation(F)V

    .line 530
    :cond_2
    new-instance v5, Landroid/widget/TextView;

    invoke-direct {v5, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 531
    const-string v9, "\u2190"

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 532
    const/4 v9, -0x1

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setTextColor(I)V

    .line 533
    const/high16 v11, 0x41b00000    # 22.0f

    invoke-virtual {v5, v11}, Landroid/widget/TextView;->setTextSize(F)V

    .line 534
    invoke-virtual {v1, v10}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v5, v10, v7, v4, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 535
    new-instance v4, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;

    invoke-direct {v4, v1, v1}, Lin/startv/hotstar/FileExplorerActivity$BackClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v5, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 536
    invoke-virtual {v6, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 539
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 540
    const-string v5, "\ud83d\udcc1 File Explorer"

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 541
    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setTextColor(I)V

    .line 542
    const/high16 v5, 0x41900000    # 18.0f

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V

    .line 543
    sget-object v10, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 544
    new-instance v10, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v11, -0x2

    const/high16 v12, 0x3f800000    # 1.0f

    invoke-direct {v10, v7, v11, v12}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 545
    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 546
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 549
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 550
    const-string v10, "\u2795"

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 551
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V

    .line 552
    const/16 v5, 0x8

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v4, v10, v7, v11, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 553
    new-instance v10, Lin/startv/hotstar/FileExplorerActivity$1;

    invoke-direct {v10, v1}, Lin/startv/hotstar/FileExplorerActivity$1;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 559
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 562
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 563
    const-string v10, "\ud83d\udd0d"

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 564
    const/high16 v10, 0x41a00000    # 20.0f

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 565
    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v4, v11, v7, v13, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 566
    new-instance v11, Lin/startv/hotstar/FileExplorerActivity$2;

    invoke-direct {v11, v1}, Lin/startv/hotstar/FileExplorerActivity$2;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v4, v11}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 572
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 575
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 576
    const-string v11, "\ud83c\udfe0"

    invoke-virtual {v4, v11}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 577
    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 578
    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v4, v11, v7, v13, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 579
    new-instance v11, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;

    invoke-direct {v11, v1, v1}, Lin/startv/hotstar/FileExplorerActivity$HomeClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v4, v11}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 580
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 583
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 584
    const-string v11, "\ud83d\udcbe"

    invoke-virtual {v4, v11}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 585
    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 586
    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v4, v10, v7, v11, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 587
    new-instance v10, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;

    invoke-direct {v10, v1, v1}, Lin/startv/hotstar/FileExplorerActivity$SdCardClickListener;-><init>(Lin/startv/hotstar/FileExplorerActivity;Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 588
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 590
    invoke-virtual {v0, v6}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 593
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 594
    new-instance v10, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v10, v9, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v10}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 595
    const v10, -0xd3d3d4

    invoke-virtual {v4, v10}, Landroid/view/View;->setBackgroundColor(I)V

    .line 596
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 599
    new-instance v4, Landroid/widget/HorizontalScrollView;

    invoke-direct {v4, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    .line 600
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    const v11, -0xe5e5e6

    invoke-virtual {v4, v11}, Landroid/widget/HorizontalScrollView;->setBackgroundColor(I)V

    .line 601
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    invoke-virtual {v4, v7}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 602
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v14

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v15

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v4, v13, v14, v15, v8}, Landroid/widget/HorizontalScrollView;->setPadding(IIII)V

    .line 604
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    .line 605
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    const v8, -0x9b4a0a

    invoke-virtual {v4, v8}, Landroid/widget/TextView;->setTextColor(I)V

    .line 606
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    const/high16 v8, 0x41500000    # 13.0f

    invoke-virtual {v4, v8}, Landroid/widget/TextView;->setTextSize(F)V

    .line 607
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v8}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 608
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    invoke-virtual {v4, v3}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 609
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    iget-object v8, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbText:Landroid/widget/TextView;

    invoke-virtual {v4, v8}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 610
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->breadcrumbLayout:Landroid/widget/HorizontalScrollView;

    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 613
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 614
    new-instance v8, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v8, v9, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v8}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 615
    invoke-virtual {v4, v10}, Landroid/view/View;->setBackgroundColor(I)V

    .line 616
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 619
    new-instance v4, Landroid/widget/ScrollView;

    invoke-direct {v4, v1}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    .line 620
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    invoke-virtual {v4, v3}, Landroid/widget/ScrollView;->setVerticalScrollBarEnabled(Z)V

    .line 621
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    invoke-virtual {v4, v7}, Landroid/widget/ScrollView;->setScrollbarFadingEnabled(Z)V

    .line 622
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v4, v9, v7, v12}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 624
    iget-object v7, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    invoke-virtual {v7, v4}, Landroid/widget/ScrollView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 626
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    .line 627
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 629
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    iget-object v7, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v7}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V

    .line 630
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->fileListScroll:Landroid/widget/ScrollView;

    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 633
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 634
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v7, v9, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v7}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 635
    invoke-virtual {v4, v10}, Landroid/view/View;->setBackgroundColor(I)V

    .line 636
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 639
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    .line 640
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    const-string v7, "Loading..."

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 641
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    const v7, -0x777778

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTextColor(I)V

    .line 642
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    const/high16 v7, 0x41400000    # 12.0f

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTextSize(F)V

    .line 643
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    sget-object v7, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 644
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v4, v11}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 645
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    const/16 v7, 0x10

    invoke-virtual {v1, v7}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v7}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v4, v8, v9, v7, v5}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 646
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 648
    invoke-virtual {v1, v0}, Lin/startv/hotstar/FileExplorerActivity;->setContentView(Landroid/view/View;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_2

    .line 652
    const/4 v0, 0x0

    :try_start_1
    invoke-virtual {v6, v0}, Landroid/widget/LinearLayout;->setAlpha(F)V

    .line 653
    const/16 v4, 0x14

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    neg-int v4, v4

    int-to-float v4, v4

    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->setTranslationY(F)V

    .line 654
    invoke-virtual {v6}, Landroid/widget/LinearLayout;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v4

    invoke-virtual {v4, v12}, Landroid/view/ViewPropertyAnimator;->alpha(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v4

    invoke-virtual {v4, v0}, Landroid/view/ViewPropertyAnimator;->translationY(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v0

    const-wide/16 v4, 0x15e

    invoke-virtual {v0, v4, v5}, Landroid/view/ViewPropertyAnimator;->setDuration(J)Landroid/view/ViewPropertyAnimator;

    move-result-object v0

    new-instance v4, Landroid/view/animation/DecelerateInterpolator;

    invoke-direct {v4}, Landroid/view/animation/DecelerateInterpolator;-><init>()V

    .line 655
    invoke-virtual {v0, v4}, Landroid/view/ViewPropertyAnimator;->setInterpolator(Landroid/animation/TimeInterpolator;)Landroid/view/ViewPropertyAnimator;

    move-result-object v0

    invoke-virtual {v0}, Landroid/view/ViewPropertyAnimator;->start()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_0

    .line 656
    :catch_0
    move-exception v0

    :try_start_2
    invoke-virtual {v6, v12}, Landroid/widget/LinearLayout;->setAlpha(F)V

    :goto_0
    nop

    .line 659
    invoke-virtual {v1}, Lin/startv/hotstar/FileExplorerActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    .line 660
    nop

    .line 661
    if-eqz v0, :cond_3

    .line 662
    const-string v4, "path"

    invoke-virtual {v0, v4}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    goto :goto_1

    .line 661
    :cond_3
    const/4 v0, 0x0

    .line 664
    :goto_1
    if-nez v0, :cond_4

    .line 665
    invoke-virtual {v1}, Lin/startv/hotstar/FileExplorerActivity;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v0

    iget-object v0, v0, Landroid/content/pm/ApplicationInfo;->dataDir:Ljava/lang/String;

    .line 667
    :cond_4
    iput-object v0, v1, Lin/startv/hotstar/FileExplorerActivity;->rootPath:Ljava/lang/String;
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    .line 670
    :try_start_3
    invoke-virtual {v1, v0}, Lin/startv/hotstar/FileExplorerActivity;->navigateTo(Ljava/lang/String;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    .line 676
    goto :goto_2

    .line 671
    :catch_1
    move-exception v0

    .line 672
    :try_start_4
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "FileExplorerActivity navigateTo error: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v2, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 673
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    if-eqz v4, :cond_5

    .line 674
    iget-object v4, v1, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Error: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v4, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_2

    .line 682
    :cond_5
    :goto_2
    goto :goto_3

    .line 678
    :catch_2
    move-exception v0

    .line 679
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v4

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "FileExplorerActivity.onCreate FATAL: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v2, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 680
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Error loading file explorer: "

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 681
    invoke-virtual {v1}, Lin/startv/hotstar/FileExplorerActivity;->finish()V

    .line 683
    :goto_3
    return-void
.end method

.method public performRecursiveSearch(Ljava/lang/String;Z)V
    .locals 7

    .line 778
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    .line 779
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v2

    .line 781
    const-string v0, "Searching..."

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 784
    new-instance v6, Ljava/lang/Thread;

    new-instance v0, Lin/startv/hotstar/FileExplorerActivity$7;

    move-object v1, p0

    move-object v5, p1

    move v3, p2

    invoke-direct/range {v0 .. v5}, Lin/startv/hotstar/FileExplorerActivity$7;-><init>(Lin/startv/hotstar/FileExplorerActivity;Ljava/lang/String;ZLjava/util/ArrayList;Ljava/lang/String;)V

    invoke-direct {v6, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    .line 796
    invoke-virtual {v6}, Ljava/lang/Thread;->start()V

    .line 797
    return-void
.end method

.method public searchRecursive(Ljava/io/File;Ljava/lang/String;ZLjava/util/ArrayList;I)V
    .locals 10
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/lang/String;",
            "Z",
            "Ljava/util/ArrayList<",
            "Ljava/io/File;",
            ">;I)V"
        }
    .end annotation

    .line 801
    const/16 v0, 0xa

    if-gt p5, v0, :cond_9

    invoke-virtual {p4}, Ljava/util/ArrayList;->size()I

    move-result v0

    const/16 v1, 0xc8

    if-le v0, v1, :cond_0

    goto/16 :goto_4

    .line 802
    :cond_0
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;

    move-result-object p1

    .line 803
    if-nez p1, :cond_1

    return-void

    .line 805
    :cond_1
    array-length v1, p1

    const/4 v2, 0x0

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v1, :cond_8

    aget-object v5, p1, v3

    .line 807
    invoke-virtual {v5}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v0

    const/4 v4, 0x1

    if-eqz v0, :cond_2

    .line 808
    invoke-virtual {p4, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    goto :goto_2

    .line 809
    :cond_2
    if-eqz p3, :cond_6

    invoke-virtual {v5}, Ljava/io/File;->isFile()Z

    move-result v0

    if-eqz v0, :cond_6

    invoke-virtual {v5}, Ljava/io/File;->length()J

    move-result-wide v6

    const-wide/32 v8, 0x500000

    cmp-long v0, v6, v8

    if-gez v0, :cond_6

    .line 812
    :try_start_0
    new-instance v0, Ljava/io/BufferedReader;

    new-instance v6, Ljava/io/InputStreamReader;

    new-instance v7, Ljava/io/FileInputStream;

    invoke-direct {v7, v5}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    const-string v8, "UTF-8"

    invoke-direct {v6, v7, v8}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    invoke-direct {v0, v6}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 814
    nop

    .line 815
    :cond_3
    invoke-virtual {v0}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object v6

    if-eqz v6, :cond_4

    .line 816
    invoke-virtual {v6}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v6, p2}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v6

    if-eqz v6, :cond_3

    .line 817
    nop

    .line 818
    const/4 v6, 0x1

    goto :goto_1

    .line 815
    :cond_4
    const/4 v6, 0x0

    .line 821
    :goto_1
    invoke-virtual {v0}, Ljava/io/BufferedReader;->close()V

    .line 822
    if-eqz v6, :cond_5

    invoke-virtual {p4, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 825
    :cond_5
    goto :goto_2

    .line 823
    :catch_0
    move-exception v0

    .line 828
    :cond_6
    :goto_2
    invoke-virtual {v5}, Ljava/io/File;->isDirectory()Z

    move-result v0

    if-eqz v0, :cond_7

    .line 829
    add-int/lit8 v9, p5, 0x1

    move-object v4, p0

    move-object v6, p2

    move v7, p3

    move-object v8, p4

    invoke-virtual/range {v4 .. v9}, Lin/startv/hotstar/FileExplorerActivity;->searchRecursive(Ljava/io/File;Ljava/lang/String;ZLjava/util/ArrayList;I)V

    goto :goto_3

    .line 828
    :cond_7
    move-object v6, p2

    move v7, p3

    move-object v8, p4

    .line 805
    :goto_3
    add-int/lit8 v3, v3, 0x1

    move-object p2, v6

    move p3, v7

    move-object p4, v8

    goto :goto_0

    .line 832
    :cond_8
    return-void

    .line 801
    :cond_9
    :goto_4
    return-void
.end method

.method public showNameInputDialog(Z)V
    .locals 6

    .line 702
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 703
    if-eqz p1, :cond_0

    const-string v1, "New Folder Name"

    goto :goto_0

    :cond_0
    const-string v1, "New File Name"

    :goto_0
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 705
    new-instance v1, Landroid/widget/EditText;

    invoke-direct {v1, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 706
    if-eqz p1, :cond_1

    const-string v2, "folder_name"

    goto :goto_1

    :cond_1
    const-string v2, "filename.txt"

    :goto_1
    invoke-virtual {v1, v2}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 707
    const/16 v2, 0x10

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    const/16 v4, 0x8

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v1, v3, v5, v2, v4}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 708
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    .line 710
    new-instance v2, Lin/startv/hotstar/FileExplorerActivity$4;

    invoke-direct {v2, p0, v1, p1}, Lin/startv/hotstar/FileExplorerActivity$4;-><init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/EditText;Z)V

    const-string p1, "Create"

    invoke-virtual {v0, p1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 735
    const-string p1, "Cancel"

    const/4 v1, 0x0

    invoke-virtual {v0, p1, v1}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 736
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 737
    return-void
.end method

.method public showNewFileDialog()V
    .locals 4

    .line 687
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 688
    const-string v1, "Create New"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 690
    const/4 v1, 0x2

    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0

    const-string v3, "New File"

    aput-object v3, v1, v2

    const/4 v2, 0x1

    const-string v3, "New Folder"

    aput-object v3, v1, v2

    .line 691
    new-instance v2, Lin/startv/hotstar/FileExplorerActivity$3;

    invoke-direct {v2, p0}, Lin/startv/hotstar/FileExplorerActivity$3;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 697
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 698
    return-void
.end method

.method public showSearchDialog()V
    .locals 8

    .line 741
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 742
    iget-object v1, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    if-eqz v1, :cond_0

    new-instance v1, Ljava/io/File;

    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity;->currentPath:Ljava/lang/String;

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v1

    goto :goto_0

    :cond_0
    const-string v1, ""

    :goto_0
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "\ud83d\udd0d Search in: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    .line 744
    new-instance v1, Landroid/widget/LinearLayout;

    invoke-direct {v1, p0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 745
    const/4 v2, 0x1

    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 746
    const/16 v3, 0x10

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    const/16 v5, 0x8

    invoke-virtual {p0, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v6

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {p0, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v4, v6, v3, v7}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 748
    new-instance v3, Landroid/widget/EditText;

    invoke-direct {v3, p0}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    .line 749
    const-string v4, "Search query..."

    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 750
    const/16 v4, 0xc

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v6

    invoke-virtual {p0, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {p0, v5}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v3, v6, v7, v4, v5}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 751
    invoke-virtual {v1, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 753
    const/4 v4, 0x2

    new-array v4, v4, [Ljava/lang/String;

    const-string v5, "Filename only"

    const/4 v6, 0x0

    aput-object v5, v4, v6

    const-string v5, "Filename + File content"

    aput-object v5, v4, v2

    .line 754
    filled-new-array {v6}, [I

    move-result-object v2

    .line 755
    new-instance v5, Lin/startv/hotstar/FileExplorerActivity$5;

    invoke-direct {v5, p0, v2}, Lin/startv/hotstar/FileExplorerActivity$5;-><init>(Lin/startv/hotstar/FileExplorerActivity;[I)V

    invoke-virtual {v0, v4, v6, v5}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 762
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    .line 763
    new-instance v1, Lin/startv/hotstar/FileExplorerActivity$6;

    invoke-direct {v1, p0, v3, v2}, Lin/startv/hotstar/FileExplorerActivity$6;-><init>(Lin/startv/hotstar/FileExplorerActivity;Landroid/widget/EditText;[I)V

    const-string v2, "Search"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 772
    const-string v1, "Cancel"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    .line 773
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    .line 774
    return-void
.end method

.method public showSearchResults(Ljava/util/ArrayList;Ljava/lang/String;)V
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/io/File;",
            ">;",
            "Ljava/lang/String;",
            ")V"
        }
    .end annotation

    .line 836
    invoke-virtual {p1}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 837
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "No results found for: "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const/4 p2, 0x1

    invoke-static {p0, p1, p2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p1

    invoke-virtual {p1}, Landroid/widget/Toast;->show()V

    .line 838
    return-void

    .line 842
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v0}, Landroid/widget/LinearLayout;->removeAllViews()V

    .line 845
    :cond_1
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 846
    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I

    move-result v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "\ud83d\udd0d "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " results for \""

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string v1, "\""

    invoke-virtual {p2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 847
    const p2, -0xff198a

    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setTextColor(I)V

    .line 848
    const/high16 p2, 0x41600000    # 14.0f

    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 849
    sget-object v1, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 850
    const/16 v1, 0x10

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    const/16 v3, 0xc

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {v0, v2, v4, v5, v3}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 851
    const v2, -0xe5d5e6

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 852
    iget-object v2, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v2, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 855
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 856
    const-string v2, "\u2190 Back to folder"

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 857
    const v2, -0xbb7501

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextColor(I)V

    .line 858
    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 859
    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result p2

    const/16 v2, 0x8

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v1

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileExplorerActivity;->dpToPx(I)I

    move-result v2

    invoke-virtual {v0, p2, v3, v1, v2}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 860
    new-instance p2, Lin/startv/hotstar/FileExplorerActivity$8;

    invoke-direct {p2, p0}, Lin/startv/hotstar/FileExplorerActivity$8;-><init>(Lin/startv/hotstar/FileExplorerActivity;)V

    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 866
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity;->fileListLayout:Landroid/widget/LinearLayout;

    invoke-virtual {p2, v0}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 867
    invoke-virtual {p0}, Lin/startv/hotstar/FileExplorerActivity;->addDivider()V

    .line 870
    const/4 p2, 0x0

    iput p2, p0, Lin/startv/hotstar/FileExplorerActivity;->itemIndex:I

    .line 871
    invoke-virtual {p1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object p2

    :goto_0
    invoke-interface {p2}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-interface {p2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/io/File;

    .line 872
    invoke-virtual {v0}, Ljava/io/File;->isDirectory()Z

    move-result v1

    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileExplorerActivity;->addFileItem(Ljava/io/File;Z)V

    .line 873
    goto :goto_0

    .line 875
    :cond_2
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    if-eqz p2, :cond_3

    .line 876
    iget-object p2, p0, Lin/startv/hotstar/FileExplorerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I

    move-result p1

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, " search results"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p2, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 878
    :cond_3
    return-void
.end method
