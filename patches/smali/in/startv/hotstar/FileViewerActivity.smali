.class public Lin/startv/hotstar/FileViewerActivity;
.super Landroid/app/Activity;
.source "FileViewerActivity.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lin/startv/hotstar/FileViewerActivity$BackClickListener;,
        Lin/startv/hotstar/FileViewerActivity$SearchActionListener;,
        Lin/startv/hotstar/FileViewerActivity$SaveClickListener;,
        Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;,
        Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;
    }
.end annotation


# static fields
.field public static final C_ACCENT:I = -0xff872c

.field public static final C_BG_EDITOR:I = -0xe1e1e2

.field public static final C_BG_LINENUM:I = -0xe1e1e2

.field public static final C_BG_MAIN:I = -0xe1e1e2

.field public static final C_BG_SEARCH:I = -0xd2d2d3

.field public static final C_BG_STATUS:I = -0xff8534

.field public static final C_BG_SYMBOL:I = -0xdadada

.field public static final C_BG_TOOLBAR:I = -0xdadada

.field public static final C_DIVIDER:I = -0xc3c3c4

.field public static final C_SEARCH_MATCH:I = -0xaea396

.field public static final C_SYMBOL_BG:I = -0xc3c3c4

.field public static final C_SYMBOL_TEXT:I = -0x333334

.field public static final C_SYN_COMMENT:I = -0x9566ab

.field public static final C_SYN_DIRECTIVE:I = -0x3a7940

.field public static final C_SYN_KEYWORD:I = -0xa9632a

.field public static final C_SYN_NUMBER:I = -0x4a3158

.field public static final C_SYN_STRING:I = -0x316e88

.field public static final C_SYN_TYPE:I = -0xb13650

.field public static final C_TEXT_EDITOR:I = -0x2b2b2c

.field public static final C_TEXT_HINT:I = -0xa5a5a6

.field public static final C_TEXT_LINENUM:I = -0x7a7a7b

.field public static final C_TEXT_TOOLBAR:I = -0x1

.field public static final SYMBOLS:[Ljava/lang/String;


# instance fields
.field public currentTextSize:F

.field public editText:Landroid/widget/EditText;

.field public editorScroll:Landroid/widget/ScrollView;

.field public filePath:Ljava/lang/String;

.field public handler:Landroid/os/Handler;

.field public highlightEnabled:Z

.field public highlightRunnable:Ljava/lang/Runnable;

.field public isBinary:Z

.field public isEdited:Z

.field public lineNumberView:Landroid/widget/TextView;

.field public matchCountText:Landroid/widget/TextView;

.field public replaceInput:Landroid/widget/EditText;

.field public searchContainer:Landroid/widget/LinearLayout;

.field public searchInput:Landroid/widget/EditText;

.field public statusText:Landroid/widget/TextView;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .line 90
    const/16 v0, 0x20

    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "Tab"

    aput-object v2, v0, v1

    const/4 v1, 0x1

    const-string v2, "{"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, "}"

    aput-object v2, v0, v1

    const/4 v1, 0x3

    const-string v2, "("

    aput-object v2, v0, v1

    const/4 v1, 0x4

    const-string v2, ")"

    aput-object v2, v0, v1

    const/4 v1, 0x5

    const-string v2, "["

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "]"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "<"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, ">"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, ";"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, ":"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "\'"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "\""

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "="

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "+"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "-"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "*"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "/"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "&"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "|"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "\\"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "_"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "#"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "@"

    aput-object v2, v0, v1

    const/16 v1, 0x18

    const-string v2, "."

    aput-object v2, v0, v1

    const/16 v1, 0x19

    const-string v2, ","

    aput-object v2, v0, v1

    const/16 v1, 0x1a

    const-string v2, "!"

    aput-object v2, v0, v1

    const/16 v1, 0x1b

    const-string v2, "?"

    aput-object v2, v0, v1

    const/16 v1, 0x1c

    const-string v2, "^"

    aput-object v2, v0, v1

    const/16 v1, 0x1d

    const-string v2, "~"

    aput-object v2, v0, v1

    const/16 v1, 0x1e

    const-string v2, "%"

    aput-object v2, v0, v1

    const/16 v1, 0x1f

    const-string v2, "0"

    aput-object v2, v0, v1

    sput-object v0, Lin/startv/hotstar/FileViewerActivity;->SYMBOLS:[Ljava/lang/String;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 46
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V

    .line 83
    const/high16 v0, 0x41600000    # 14.0f

    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    .line 85
    const/4 v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightEnabled:Z

    .line 86
    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    return-void
.end method

.method public static readFileContent(Ljava/lang/String;)Ljava/lang/String;
    .locals 9

    .line 100
    const/4 v0, 0x0

    :try_start_0
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 101
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_0

    return-object v0

    .line 102
    :cond_0
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v2

    .line 103
    const-wide/32 v4, 0x3200000

    cmp-long p0, v2, v4

    if-lez p0, :cond_1

    return-object v0

    .line 105
    :cond_1
    new-instance p0, Ljava/io/FileInputStream;

    invoke-direct {p0, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 106
    long-to-int v3, v2

    const/16 v2, 0x2000

    invoke-static {v3, v2}, Ljava/lang/Math;->min(II)I

    move-result v3

    new-array v3, v3, [B

    .line 107
    invoke-virtual {p0, v3}, Ljava/io/FileInputStream;->read([B)I

    move-result v4

    .line 110
    const/4 v5, 0x0

    if-lez v4, :cond_4

    .line 111
    nop

    .line 112
    const/4 v6, 0x0

    const/4 v7, 0x0

    :goto_0
    if-ge v6, v4, :cond_3

    .line 113
    aget-byte v8, v3, v6

    if-nez v8, :cond_2

    add-int/lit8 v7, v7, 0x1

    .line 112
    :cond_2
    add-int/lit8 v6, v6, 0x1

    goto :goto_0

    .line 115
    :cond_3
    div-int/lit8 v4, v4, 0xa

    if-le v7, v4, :cond_4

    .line 116
    invoke-virtual {p0}, Ljava/io/FileInputStream;->close()V

    .line 117
    return-object v0

    .line 120
    :cond_4
    invoke-virtual {p0}, Ljava/io/FileInputStream;->close()V

    .line 123
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    .line 124
    new-instance v3, Ljava/io/BufferedReader;

    new-instance v4, Ljava/io/InputStreamReader;

    new-instance v6, Ljava/io/FileInputStream;

    invoke-direct {v6, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    const-string v1, "UTF-8"

    invoke-direct {v4, v6, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    invoke-direct {v3, v4}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 125
    new-array v1, v2, [C

    .line 127
    :goto_1
    invoke-virtual {v3, v1}, Ljava/io/BufferedReader;->read([C)I

    move-result v2

    const/4 v4, -0x1

    if-eq v2, v4, :cond_5

    .line 128
    invoke-virtual {p0, v1, v5, v2}, Ljava/lang/StringBuilder;->append([CII)Ljava/lang/StringBuilder;

    goto :goto_1

    .line 130
    :cond_5
    invoke-virtual {v3}, Ljava/io/BufferedReader;->close()V

    .line 131
    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object p0

    .line 132
    :catch_0
    move-exception p0

    .line 133
    invoke-virtual {p0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "readFileContent error: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v1, "HSPatch"

    invoke-static {v1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 134
    return-object v0
.end method

.method public static writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 2

    .line 141
    :try_start_0
    new-instance v0, Ljava/io/BufferedWriter;

    new-instance v1, Ljava/io/FileWriter;

    invoke-direct {v1, p0}, Ljava/io/FileWriter;-><init>(Ljava/lang/String;)V

    invoke-direct {v0, v1}, Ljava/io/BufferedWriter;-><init>(Ljava/io/Writer;)V

    .line 142
    invoke-virtual {v0, p1}, Ljava/io/BufferedWriter;->write(Ljava/lang/String;)V

    .line 143
    invoke-virtual {v0}, Ljava/io/BufferedWriter;->flush()V

    .line 144
    invoke-virtual {v0}, Ljava/io/BufferedWriter;->close()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 145
    const/4 p0, 0x1

    return p0

    .line 146
    :catch_0
    move-exception p0

    .line 147
    invoke-virtual {p0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p0

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "writeFileContent error: "

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string p1, "HSPatch"

    invoke-static {p1, p0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 148
    const/4 p0, 0x0

    return p0
.end method


# virtual methods
.method public animateEntrance(Landroid/view/View;I)V
    .locals 5

    .line 534
    const/high16 v0, 0x3f800000    # 1.0f

    const/4 v1, 0x0

    :try_start_0
    invoke-virtual {p1, v1}, Landroid/view/View;->setAlpha(F)V

    .line 535
    const/16 v2, 0xc

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v2

    int-to-float v2, v2

    invoke-virtual {p1, v2}, Landroid/view/View;->setTranslationY(F)V

    .line 536
    invoke-virtual {p1}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 537
    invoke-virtual {v2, v0}, Landroid/view/ViewPropertyAnimator;->alpha(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 538
    invoke-virtual {v2, v1}, Landroid/view/ViewPropertyAnimator;->translationY(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 539
    const-wide/16 v3, 0x12c

    invoke-virtual {v2, v3, v4}, Landroid/view/ViewPropertyAnimator;->setDuration(J)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    int-to-long v3, p2

    .line 540
    invoke-virtual {v2, v3, v4}, Landroid/view/ViewPropertyAnimator;->setStartDelay(J)Landroid/view/ViewPropertyAnimator;

    move-result-object p2

    new-instance v2, Landroid/view/animation/DecelerateInterpolator;

    invoke-direct {v2}, Landroid/view/animation/DecelerateInterpolator;-><init>()V

    .line 541
    invoke-virtual {p2, v2}, Landroid/view/ViewPropertyAnimator;->setInterpolator(Landroid/animation/TimeInterpolator;)Landroid/view/ViewPropertyAnimator;

    move-result-object p2

    .line 542
    invoke-virtual {p2}, Landroid/view/ViewPropertyAnimator;->start()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 546
    goto :goto_0

    .line 543
    :catch_0
    move-exception p2

    .line 544
    invoke-virtual {p1, v0}, Landroid/view/View;->setAlpha(F)V

    .line 545
    invoke-virtual {p1, v1}, Landroid/view/View;->setTranslationY(F)V

    .line 547
    :goto_0
    return-void
.end method

.method public applySyntaxHighlighting()V
    .locals 7

    .line 339
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_c

    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightEnabled:Z

    if-nez v0, :cond_0

    goto/16 :goto_a

    .line 340
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    .line 341
    if-nez v0, :cond_1

    return-void

    .line 342
    :cond_1
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 343
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    const v3, 0x249f0

    if-le v2, v3, :cond_2

    return-void

    .line 346
    :cond_2
    invoke-interface {v0}, Landroid/text/Editable;->length()I

    move-result v2

    const-class v3, Landroid/text/style/ForegroundColorSpan;

    const/4 v4, 0x0

    invoke-interface {v0, v4, v2, v3}, Landroid/text/Editable;->getSpans(IILjava/lang/Class;)[Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [Landroid/text/style/ForegroundColorSpan;

    .line 347
    array-length v3, v2

    :goto_0
    if-ge v4, v3, :cond_3

    aget-object v5, v2, v4

    .line 348
    invoke-interface {v0, v5}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 347
    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    .line 353
    :cond_3
    :try_start_0
    const-string v2, "(?m)^\\s*#.*$"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 354
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 355
    :goto_1
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    const/16 v4, 0x21

    if-eqz v3, :cond_4

    .line 356
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x9566ab

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 357
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 356
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_1

    .line 361
    :cond_4
    const-string v2, "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\""

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 362
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 363
    :goto_2
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_5

    .line 364
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x316e88

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 365
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 364
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_2

    .line 369
    :cond_5
    const-string v2, "(?m)^\\s*\\.(class|method|field|end|super|source|locals|line|param|annotation|registers|implements|prologue|enum|subannotation)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 370
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 371
    :goto_3
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_6

    .line 372
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x3a7940

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 373
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 372
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_3

    .line 377
    :cond_6
    const-string v2, "\\b(invoke-(?:virtual|static|direct|super|interface|polymorphic)(?:/range)?|move-?(?:result)?(?:-object|-wide|-exception)?(?:/(?:from16|16))?|const(?:-string|-class|/(?:high16|4|16))?(?:/jumbo)?|return(?:-void|-object|-wide)?|if-(?:eq|ne|lt|ge|gt|le|eqz|nez|ltz|gez|gtz|lez)|goto(?:/(?:16|32))?|new-instance|new-array|check-cast|instance-of|throw|monitor-(?:enter|exit)|sget(?:-object|-boolean|-wide|-byte|-short|-char)?|sput(?:-object|-boolean|-wide|-byte|-short|-char)?|iget(?:-object|-boolean|-wide|-byte|-short|-char)?|iput(?:-object|-boolean|-wide|-byte|-short|-char)?|aget(?:-object|-boolean|-wide|-byte|-short|-char)?|aput(?:-object|-boolean|-wide|-byte|-short|-char)?|filled-new-array(?:/range)?|array-length|nop|packed-switch|sparse-switch|fill-array-data|add-int|sub-int|mul-int|div-int|rem-int|and-int|or-int|xor-int|shl-int|shr-int|ushr-int|neg-int|not-int|int-to-long|int-to-float|int-to-double|long-to-int|long-to-float|long-to-double|float-to-int|float-to-long|float-to-double|double-to-int|double-to-long|double-to-float|int-to-byte|int-to-char|int-to-short|add-long|sub-long|mul-long|div-long|cmp-long|cmpl-float|cmpg-float|cmpl-double|cmpg-double|add-float|sub-float|mul-float|div-float|add-double|sub-double|mul-double|div-double)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 378
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 379
    :goto_4
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_7

    .line 380
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0xa9632a

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 381
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 380
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_4

    .line 385
    :cond_7
    const-string v2, "L[a-zA-Z][a-zA-Z0-9_/\\$]*;"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 386
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 387
    :goto_5
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_8

    .line 388
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0xb13650

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 389
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 388
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_5

    .line 393
    :cond_8
    const-string v2, "\\b(?:0x[0-9a-fA-F]+|-?\\d+(?:\\.\\d+)?)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 394
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 395
    :goto_6
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_9

    .line 396
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x4a3158

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 397
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 396
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_6

    .line 401
    :cond_9
    const-string v2, ":[a-zA-Z_][a-zA-Z0-9_]*"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 402
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 403
    :goto_7
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_a

    .line 404
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x232356

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 405
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 404
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_7

    .line 409
    :cond_a
    const-string v2, "\\b[vp]\\d{1,2}\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 410
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v1

    .line 411
    :goto_8
    invoke-virtual {v1}, Ljava/util/regex/Matcher;->find()Z

    move-result v2

    if-eqz v2, :cond_b

    .line 412
    new-instance v2, Landroid/text/style/ForegroundColorSpan;

    const v3, -0x632302

    invoke-direct {v2, v3}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 413
    invoke-virtual {v1}, Ljava/util/regex/Matcher;->start()I

    move-result v3

    invoke-virtual {v1}, Ljava/util/regex/Matcher;->end()I

    move-result v5

    .line 412
    invoke-interface {v0, v2, v3, v5, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_8

    .line 417
    :cond_b
    goto :goto_9

    .line 415
    :catch_0
    move-exception v0

    .line 416
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Syntax highlighting error: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "HSPatch"

    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 418
    :goto_9
    return-void

    .line 339
    :cond_c
    :goto_a
    return-void
.end method

.method public createSymbolButton(Ljava/lang/String;)Landroid/widget/TextView;
    .locals 7

    .line 482
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 483
    const-string v1, "Tab"

    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "\u21e5"

    goto :goto_0

    :cond_0
    move-object v2, p1

    :goto_0
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 484
    const v2, -0x333334

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextColor(I)V

    .line 485
    const/high16 v2, 0x41800000    # 16.0f

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 486
    const/16 v2, 0x11

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setGravity(I)V

    .line 487
    sget-object v2, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 489
    const/16 v2, 0xe

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v2

    .line 490
    const/16 v3, 0x8

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v3

    .line 491
    invoke-virtual {v0, v2, v3, v2, v3}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 493
    new-instance v2, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v2}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 494
    const/4 v3, 0x4

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    int-to-float v4, v4

    invoke-virtual {v2, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 495
    const v4, -0xc3c3c4

    invoke-virtual {v2, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 496
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 499
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v4, -0x2

    invoke-direct {v2, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 501
    const/4 v4, 0x2

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v6

    invoke-virtual {p0, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {v2, v5, v6, v4, v3}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 502
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 505
    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 506
    const-string p1, "    "

    goto :goto_1

    .line 508
    :cond_1
    nop

    .line 511
    :goto_1
    new-instance v1, Lin/startv/hotstar/FileViewerActivity$1;

    invoke-direct {v1, p0, p1}, Lin/startv/hotstar/FileViewerActivity$1;-><init>(Lin/startv/hotstar/FileViewerActivity;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 523
    return-object v0
.end method

.method public createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;
    .locals 2

    .line 462
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 463
    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 464
    const/4 p1, -0x1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTextColor(I)V

    .line 465
    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 466
    const/16 p1, 0x11

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setGravity(I)V

    .line 468
    const/16 p1, 0xc

    invoke-virtual {p0, p1}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p1

    .line 469
    const/16 p2, 0x8

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v1

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p2

    invoke-virtual {v0, p1, v1, p1, p2}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 472
    new-instance p1, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {p1}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 473
    const/4 p2, 0x6

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p2

    int-to-float p2, p2

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 474
    const/4 p2, 0x0

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 475
    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 477
    return-object v0
.end method

.method public doReplace()V
    .locals 5

    .line 251
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_4

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_4

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_1

    .line 252
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 253
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 254
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1

    return-void

    .line 256
    :cond_1
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v2

    .line 257
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getSelectionEnd()I

    move-result v3

    .line 258
    if-ltz v2, :cond_3

    if-le v3, v2, :cond_3

    .line 259
    iget-object v4, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v4}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    .line 260
    invoke-virtual {v4, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    .line 261
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-interface {v0, v2, v3, v1}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 262
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    .line 264
    :cond_2
    goto :goto_0

    .line 265
    :cond_3
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    .line 267
    :goto_0
    return-void

    .line 251
    :cond_4
    :goto_1
    return-void
.end method

.method public doReplaceAll()V
    .locals 7

    .line 271
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_4

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_4

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_3

    .line 272
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 273
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 274
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1

    return-void

    .line 277
    :cond_1
    const/4 v2, 0x0

    :try_start_0
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    .line 278
    invoke-virtual {v3, v0, v1}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v1

    .line 279
    invoke-virtual {v3, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_3

    .line 281
    nop

    .line 282
    const/4 v4, 0x0

    const/4 v5, 0x0

    .line 283
    :goto_0
    invoke-virtual {v3, v0, v4}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v4

    if-ltz v4, :cond_2

    .line 284
    add-int/lit8 v5, v5, 0x1

    .line 285
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v6

    add-int/2addr v4, v6

    goto :goto_0

    .line 287
    :cond_2
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 288
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Replaced "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " occurrences"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 289
    goto :goto_1

    .line 290
    :cond_3
    const-string v0, "No matches found"

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 295
    :goto_1
    goto :goto_2

    .line 292
    :catch_0
    move-exception v0

    .line 293
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v1

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "doReplaceAll error: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v3, "HSPatch"

    invoke-static {v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 294
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Replace error: "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 296
    :goto_2
    return-void

    .line 271
    :cond_4
    :goto_3
    return-void
.end method

.method public dpToPx(I)I
    .locals 1

    .line 528
    int-to-float p1, p1

    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->getResources()Landroid/content/res/Resources;

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

.method public findNext()V
    .locals 5

    .line 189
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_6

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_1

    .line 190
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 191
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_1

    return-void

    .line 193
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 194
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionEnd()I

    move-result v2

    .line 195
    const/4 v3, 0x0

    if-gez v2, :cond_2

    const/4 v2, 0x0

    .line 197
    :cond_2
    invoke-virtual {v1, v0, v2}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v2

    .line 198
    if-gez v2, :cond_3

    .line 199
    invoke-virtual {v1, v0, v3}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v2

    .line 202
    :cond_3
    if-ltz v2, :cond_4

    .line 203
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v4

    add-int/2addr v4, v2

    invoke-virtual {v3, v2, v4}, Landroid/widget/EditText;->setSelection(II)V

    .line 204
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->requestFocus()Z

    .line 205
    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 207
    :cond_4
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v1, "0"

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 208
    :cond_5
    const-string v0, "Not found"

    invoke-static {p0, v0, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 210
    :goto_0
    return-void

    .line 189
    :cond_6
    :goto_1
    return-void
.end method

.method public findPrev()V
    .locals 5

    .line 214
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_6

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_1

    .line 215
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 216
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_1

    return-void

    .line 218
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 219
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    .line 220
    if-gez v2, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    .line 222
    :cond_2
    invoke-virtual {v1, v0, v2}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;I)I

    move-result v2

    .line 223
    if-gez v2, :cond_3

    .line 224
    invoke-virtual {v1, v0}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I

    move-result v2

    .line 227
    :cond_3
    if-ltz v2, :cond_4

    .line 228
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v4

    add-int/2addr v4, v2

    invoke-virtual {v3, v2, v4}, Landroid/widget/EditText;->setSelection(II)V

    .line 229
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->requestFocus()Z

    .line 230
    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 232
    :cond_4
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v1, "0"

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 233
    :cond_5
    const-string v0, "Not found"

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 235
    :goto_0
    return-void

    .line 214
    :cond_6
    :goto_1
    return-void
.end method

.method public getFileName()Ljava/lang/String;
    .locals 2

    .line 154
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-nez v0, :cond_0

    const-string v0, "Untitled"

    return-object v0

    .line 155
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    const/16 v1, 0x2f

    invoke-virtual {v0, v1}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v0

    .line 156
    if-ltz v0, :cond_1

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    if-ge v0, v1, :cond_1

    .line 157
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    add-int/lit8 v0, v0, 0x1

    invoke-virtual {v1, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 159
    :cond_1
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    return-object v0
.end method

.method public onBackPressed()V
    .locals 3

    .line 930
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    if-eqz v0, :cond_0

    .line 931
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 932
    const-string v1, "Unsaved Changes"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 933
    const-string v1, "You have unsaved changes. Save before closing?"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lin/startv/hotstar/FileViewerActivity$3;

    invoke-direct {v1, p0}, Lin/startv/hotstar/FileViewerActivity$3;-><init>(Lin/startv/hotstar/FileViewerActivity;)V

    .line 934
    const-string v2, "Save"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;

    invoke-direct {v1, p0, p0}, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    .line 940
    const-string v2, "Discard"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 941
    const-string v1, "Cancel"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNeutralButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 942
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0

    .line 944
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->finish()V

    .line 946
    :goto_0
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 16

    .line 552
    move-object/from16 v1, p0

    invoke-super/range {p0 .. p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 556
    const/4 v2, 0x1

    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x15

    const v4, -0xdadada

    if-lt v0, v3, :cond_0

    .line 557
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/view/Window;->setStatusBarColor(I)V

    .line 559
    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1c

    if-lt v0, v3, :cond_1

    .line 560
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/view/Window;->setNavigationBarColor(I)V

    .line 564
    :cond_1
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    const-string v3, "filePath"

    invoke-virtual {v0, v3}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iput-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    .line 567
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 568
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 569
    const v3, -0xe1e1e2

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 572
    new-instance v5, Landroid/widget/LinearLayout;

    invoke-direct {v5, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 573
    const/4 v6, 0x0

    invoke-virtual {v5, v6}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 574
    const/16 v7, 0x10

    invoke-virtual {v5, v7}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 575
    invoke-virtual {v5, v4}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 576
    const/16 v8, 0x8

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v5, v9, v10, v11, v12}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 579
    const-string v9, "\u2190"

    const/high16 v10, 0x41b00000    # 22.0f

    invoke-virtual {v1, v9, v10}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v9

    .line 580
    new-instance v10, Lin/startv/hotstar/FileViewerActivity$BackClickListener;

    invoke-direct {v10, v1, v1}, Lin/startv/hotstar/FileViewerActivity$BackClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 581
    invoke-virtual {v5, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 584
    new-instance v9, Landroid/widget/TextView;

    invoke-direct {v9, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 585
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getFileName()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 586
    const/4 v10, -0x1

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setTextColor(I)V

    .line 587
    const/high16 v11, 0x41800000    # 16.0f

    invoke-virtual {v9, v11}, Landroid/widget/TextView;->setTextSize(F)V

    .line 588
    sget-object v12, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 589
    invoke-virtual {v9, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 590
    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    const/4 v13, 0x4

    invoke-virtual {v1, v13}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v14

    invoke-virtual {v9, v12, v6, v14, v6}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 591
    new-instance v12, Landroid/widget/LinearLayout$LayoutParams;

    const/high16 v14, 0x3f800000    # 1.0f

    const/4 v15, -0x2

    invoke-direct {v12, v6, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 592
    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 593
    invoke-virtual {v5, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 596
    const-string v9, "A\u2212"

    invoke-virtual {v1, v9, v11}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v9

    .line 597
    new-instance v12, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v3, 0x7

    invoke-direct {v12, v1, v1, v3}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 598
    invoke-virtual {v5, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 601
    const-string v3, "A+"

    invoke-virtual {v1, v3, v11}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v3

    .line 602
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v12, 0x6

    invoke-direct {v9, v1, v1, v12}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v3, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 603
    invoke-virtual {v5, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 606
    const-string v3, "\ud83d\udd0d"

    const/high16 v9, 0x41a00000    # 20.0f

    invoke-virtual {v1, v3, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v3

    .line 607
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    invoke-direct {v4, v1, v1, v6}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 608
    invoke-virtual {v5, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 611
    const-string v3, "\ud83d\udcbe"

    invoke-virtual {v1, v3, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v3

    .line 612
    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;

    invoke-direct {v4, v1, v1}, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 613
    invoke-virtual {v5, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 615
    invoke-virtual {v0, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 618
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 619
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v4, v10, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 620
    const v4, -0xc3c3c4

    invoke-virtual {v3, v4}, Landroid/view/View;->setBackgroundColor(I)V

    .line 621
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 624
    new-instance v3, Landroid/widget/LinearLayout;

    invoke-direct {v3, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    iput-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    .line 625
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v3, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 626
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const v9, -0xd2d2d3

    invoke-virtual {v3, v9}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 627
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v3, v9, v10, v11, v13}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 628
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v3, v8}, Landroid/widget/LinearLayout;->setVisibility(I)V

    .line 631
    new-instance v3, Landroid/widget/LinearLayout;

    invoke-direct {v3, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 632
    invoke-virtual {v3, v6}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 633
    invoke-virtual {v3, v7}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 635
    new-instance v9, Landroid/widget/EditText;

    invoke-direct {v9, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    .line 636
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const-string v10, "Search..."

    invoke-virtual {v9, v10}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 637
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v10, -0xa5a5a6

    invoke-virtual {v9, v10}, Landroid/widget/EditText;->setHintTextColor(I)V

    .line 638
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v11, -0x2b2b2c

    invoke-virtual {v9, v11}, Landroid/widget/EditText;->setTextColor(I)V

    .line 639
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const/high16 v13, 0x41600000    # 14.0f

    invoke-virtual {v9, v13}, Landroid/widget/EditText;->setTextSize(F)V

    .line 640
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 641
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v4}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 642
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v9, v4, v11, v10, v8}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 643
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v8, 0x80001

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 644
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v4, v6, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 645
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v4, v6, v6, v10, v6}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 646
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v4}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 647
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 650
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    .line 651
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v9, "0"

    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 652
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const v9, -0x7a7a7b

    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setTextColor(I)V

    .line 653
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const/high16 v10, 0x41400000    # 12.0f

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 654
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v11, v6, v9, v6}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 655
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 658
    const-string v4, "\u25b2"

    invoke-virtual {v1, v4, v13}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    .line 659
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v11, 0x2

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 660
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 663
    const-string v4, "\u25bc"

    invoke-virtual {v1, v4, v13}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    .line 664
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    invoke-direct {v9, v1, v1, v2}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 665
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 668
    const-string v4, "\u2715"

    const/high16 v9, 0x41800000    # 16.0f

    invoke-virtual {v1, v4, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    .line 669
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v11, 0x5

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 670
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 672
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 675
    new-instance v3, Landroid/widget/LinearLayout;

    invoke-direct {v3, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 676
    invoke-virtual {v3, v6}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 677
    invoke-virtual {v3, v7}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 678
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v3, v6, v4, v6, v6}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 680
    new-instance v4, Landroid/widget/EditText;

    invoke-direct {v4, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    .line 681
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const-string v9, "Replace..."

    invoke-virtual {v4, v9}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 682
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0xa5a5a6

    invoke-virtual {v4, v9}, Landroid/widget/EditText;->setHintTextColor(I)V

    .line 683
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0x2b2b2c

    invoke-virtual {v4, v9}, Landroid/widget/EditText;->setTextColor(I)V

    .line 684
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v4, v13}, Landroid/widget/EditText;->setTextSize(F)V

    .line 685
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v4, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 686
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0xc3c3c4

    invoke-virtual {v4, v9}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 687
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v13, v7, v11, v9}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 688
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 689
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v4, v6, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 690
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v4, v6, v6, v7, v6}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 691
    iget-object v7, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v7, v4}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 692
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 695
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 696
    const-string v7, "Replace"

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 697
    const/4 v7, -0x1

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTextColor(I)V

    .line 698
    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 699
    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v7, v8, v11, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 700
    new-instance v7, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v7}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 701
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    int-to-float v8, v8

    invoke-virtual {v7, v8}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 702
    const v8, -0xff872c

    invoke-virtual {v7, v8}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 703
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 704
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v7, v15, v15}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 706
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v7, v6, v6, v8, v6}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 707
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 708
    new-instance v7, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v8, 0x3

    invoke-direct {v7, v1, v1, v8}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 709
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 712
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 713
    const-string v7, "All"

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 714
    const/4 v7, -0x1

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTextColor(I)V

    .line 715
    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 716
    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v7, v8, v11, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 717
    new-instance v7, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v7}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 718
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    int-to-float v8, v8

    invoke-virtual {v7, v8}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 719
    const v8, -0xff872c

    invoke-virtual {v7, v8}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 720
    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 721
    new-instance v7, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v9, 0x4

    invoke-direct {v7, v1, v1, v9}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 722
    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 724
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 725
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 728
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 729
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v7, -0x1

    invoke-direct {v4, v7, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 730
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 731
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 734
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 735
    const v4, -0xdadada

    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->setBackgroundColor(I)V

    .line 736
    invoke-virtual {v3, v6}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 737
    const/16 v4, 0xc

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v3, v7, v8, v11, v12}, Landroid/widget/HorizontalScrollView;->setPadding(IIII)V

    .line 739
    new-instance v7, Landroid/widget/TextView;

    invoke-direct {v7, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 740
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v8, :cond_2

    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    goto :goto_0

    :cond_2
    const-string v8, ""

    :goto_0
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 741
    const v8, -0x7a7a7b

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTextColor(I)V

    .line 742
    const/high16 v8, 0x41300000    # 11.0f

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTextSize(F)V

    .line 743
    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 744
    invoke-virtual {v7, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 745
    invoke-virtual {v3, v7}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 746
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 749
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 750
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v8, -0x1

    invoke-direct {v7, v8, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v7}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 751
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 752
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 755
    new-instance v3, Landroid/widget/ScrollView;

    invoke-direct {v3, v1}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V

    iput-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    .line 756
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v3, v2}, Landroid/widget/ScrollView;->setVerticalScrollBarEnabled(Z)V

    .line 757
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v3, v6}, Landroid/widget/ScrollView;->setScrollbarFadingEnabled(Z)V

    .line 758
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v7, -0x1

    invoke-direct {v3, v7, v6, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 760
    iget-object v7, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v7, v3}, Landroid/widget/ScrollView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 762
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 763
    invoke-virtual {v3, v2}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 764
    invoke-virtual {v3, v2}, Landroid/widget/HorizontalScrollView;->setFillViewport(Z)V

    .line 766
    new-instance v7, Landroid/widget/LinearLayout;

    invoke-direct {v7, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 767
    invoke-virtual {v7, v6}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 770
    new-instance v8, Landroid/widget/TextView;

    invoke-direct {v8, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    .line 771
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const v9, -0x7a7a7b

    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextColor(I)V

    .line 772
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v9, v1, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextSize(F)V

    .line 773
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    sget-object v9, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 774
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const/4 v9, 0x5

    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setGravity(I)V

    .line 775
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    const/4 v12, 0x4

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v8, v11, v13, v4, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 776
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const v8, -0xe1e1e2

    invoke-virtual {v4, v8}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 777
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const-string v8, "  1"

    invoke-virtual {v4, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 779
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setFocusable(Z)V

    .line 780
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v4, v6}, Landroid/widget/TextView;->setClickable(Z)V

    .line 781
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v7, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 784
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 785
    new-instance v8, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v9, -0x1

    invoke-direct {v8, v2, v9}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v8}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 786
    const v9, -0xc3c3c4

    invoke-virtual {v4, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 787
    invoke-virtual {v7, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 790
    new-instance v4, Landroid/widget/EditText;

    invoke-direct {v4, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    .line 791
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v9, -0x2b2b2c

    invoke-virtual {v4, v9}, Landroid/widget/EditText;->setTextColor(I)V

    .line 792
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v8, v1, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setTextSize(F)V

    .line 793
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V

    .line 794
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, -0xe1e1e2

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 795
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    const/16 v12, 0x10

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v4, v8, v11, v13, v12}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 796
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const/16 v8, 0x33

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setGravity(I)V

    .line 797
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, 0xa0001

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 800
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setHorizontallyScrolling(Z)V

    .line 801
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v4, v6}, Landroid/widget/EditText;->setVerticalScrollBarEnabled(Z)V

    .line 804
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v4, v15, v15}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 806
    iput v6, v4, Landroid/widget/LinearLayout$LayoutParams;->width:I

    .line 807
    iput v14, v4, Landroid/widget/LinearLayout$LayoutParams;->weight:F

    .line 808
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v8, v4}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 811
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, 0x40569cd6

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->setHighlightColor(I)V

    .line 814
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    new-instance v8, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;

    invoke-direct {v8, v1, v1}, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v4, v8}, Landroid/widget/EditText;->addTextChangedListener(Landroid/text/TextWatcher;)V

    .line 816
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v7, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 818
    invoke-virtual {v3, v7}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 819
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v4, v3}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V

    .line 820
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 823
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 824
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v7, -0x1

    invoke-direct {v4, v7, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 825
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 826
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 829
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 830
    const v4, -0xdadada

    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->setBackgroundColor(I)V

    .line 831
    invoke-virtual {v3, v6}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 832
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v3, v4, v6, v7, v6}, Landroid/widget/HorizontalScrollView;->setPadding(IIII)V

    .line 834
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 835
    invoke-virtual {v4, v6}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 836
    const/16 v12, 0x10

    invoke-virtual {v4, v12}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 838
    sget-object v7, Lin/startv/hotstar/FileViewerActivity;->SYMBOLS:[Ljava/lang/String;

    array-length v8, v7

    const/4 v9, 0x0

    :goto_1
    if-ge v9, v8, :cond_3

    aget-object v11, v7, v9

    .line 839
    invoke-virtual {v1, v11}, Lin/startv/hotstar/FileViewerActivity;->createSymbolButton(Ljava/lang/String;)Landroid/widget/TextView;

    move-result-object v11

    invoke-virtual {v4, v11}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 838
    add-int/lit8 v9, v9, 0x1

    goto :goto_1

    .line 842
    :cond_3
    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 843
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 846
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 847
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v8, -0x1

    invoke-direct {v7, v8, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v7}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 848
    const v9, -0xc3c3c4

    invoke-virtual {v4, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 849
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 852
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    .line 853
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/4 v7, -0x1

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTextColor(I)V

    .line 854
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 855
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    sget-object v7, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 856
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const v7, -0xff8534

    invoke-virtual {v4, v7}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 857
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/16 v7, 0xc

    invoke-virtual {v1, v7}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v7}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v7

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v8, v10, v7, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 858
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v4, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 859
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 861
    invoke-virtual {v1, v0}, Lin/startv/hotstar/FileViewerActivity;->setContentView(Landroid/view/View;)V

    .line 864
    invoke-virtual {v1, v5, v6}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 865
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    const/16 v4, 0x64

    invoke-virtual {v1, v0, v4}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 866
    const/16 v0, 0xc8

    invoke-virtual {v1, v3, v0}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 867
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/16 v3, 0xfa

    invoke-virtual {v1, v0, v3}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 870
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_6

    .line 871
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-static {v0}, Lin/startv/hotstar/FileViewerActivity;->readFileContent(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 872
    if-eqz v0, :cond_4

    .line 873
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 874
    iput-boolean v6, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    .line 877
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    new-instance v3, Lin/startv/hotstar/FileViewerActivity$2;

    invoke-direct {v3, v1}, Lin/startv/hotstar/FileViewerActivity$2;-><init>(Lin/startv/hotstar/FileViewerActivity;)V

    const-wide/16 v4, 0xc8

    invoke-virtual {v0, v3, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_2

    .line 889
    :cond_4
    new-instance v0, Ljava/io/File;

    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-direct {v0, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 890
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-eqz v0, :cond_5

    .line 891
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const-string v3, "[Binary file - cannot display]"

    invoke-virtual {v0, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 892
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0, v6}, Landroid/widget/EditText;->setEnabled(Z)V

    .line 893
    iput-boolean v2, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    goto :goto_2

    .line 895
    :cond_5
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const-string v3, ""

    invoke-virtual {v0, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 896
    iput-boolean v6, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    .line 901
    :cond_6
    :goto_2
    iput-boolean v6, v1, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    .line 902
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 903
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->updateStatusBar()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 909
    goto :goto_3

    .line 905
    :catch_0
    move-exception v0

    .line 906
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v3

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "FileViewerActivity.onCreate FATAL: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "HSPatch"

    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 907
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Error loading editor: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 908
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->finish()V

    .line 910
    :goto_3
    return-void
.end method

.method protected onDestroy()V
    .locals 2

    .line 916
    :try_start_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    if-eqz v0, :cond_0

    .line 917
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 919
    :cond_0
    const/4 v0, 0x0

    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    .line 920
    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 923
    goto :goto_0

    .line 921
    :catch_0
    move-exception v0

    .line 924
    :goto_0
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    .line 925
    return-void
.end method

.method public saveFile()V
    .locals 2

    .line 164
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_2

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_1

    .line 165
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 166
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-static {v1, v0}, Lin/startv/hotstar/FileViewerActivity;->writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v0

    .line 167
    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 168
    iput-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    .line 169
    const-string v0, "Saved successfully"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 170
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateStatusBar()V

    goto :goto_0

    .line 172
    :cond_1
    const-string v0, "Save failed!"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 174
    :goto_0
    return-void

    .line 164
    :cond_2
    :goto_1
    return-void
.end method

.method public toggleSearch()V
    .locals 2

    .line 178
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    if-nez v0, :cond_0

    return-void

    .line 179
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v0}, Landroid/widget/LinearLayout;->getVisibility()I

    move-result v0

    if-nez v0, :cond_1

    .line 180
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const/16 v1, 0x8

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setVisibility(I)V

    goto :goto_0

    .line 182
    :cond_1
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setVisibility(I)V

    .line 183
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->requestFocus()Z

    .line 185
    :goto_0
    return-void
.end method

.method public updateLineNumbers()V
    .locals 9

    .line 320
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-nez v0, :cond_0

    goto :goto_2

    .line 321
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 322
    nop

    .line 323
    const/4 v1, 0x0

    const/4 v2, 0x1

    const/4 v3, 0x0

    const/4 v4, 0x1

    :goto_0
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v5

    const/16 v6, 0xa

    if-ge v3, v5, :cond_2

    .line 324
    invoke-virtual {v0, v3}, Ljava/lang/String;->charAt(I)C

    move-result v5

    if-ne v5, v6, :cond_1

    add-int/lit8 v4, v4, 0x1

    .line 323
    :cond_1
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 327
    :cond_2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 328
    invoke-static {v4}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    .line 329
    const/4 v5, 0x3

    invoke-static {v3, v5}, Ljava/lang/Math;->max(II)I

    move-result v3

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, "%"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "d"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 330
    const/4 v5, 0x1

    :goto_1
    if-gt v5, v4, :cond_4

    .line 331
    if-le v5, v2, :cond_3

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 332
    :cond_3
    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    new-array v8, v2, [Ljava/lang/Object;

    aput-object v7, v8, v1

    invoke-static {v3, v8}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 330
    add-int/lit8 v5, v5, 0x1

    goto :goto_1

    .line 334
    :cond_4
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 335
    return-void

    .line 320
    :cond_5
    :goto_2
    return-void
.end method

.method public updateMatchCount(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3

    .line 239
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-eqz v0, :cond_2

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_1

    .line 240
    :cond_0
    nop

    .line 241
    const/4 v0, 0x0

    const/4 v1, 0x0

    .line 242
    :goto_0
    invoke-virtual {p2, p1, v0}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v0

    if-ltz v0, :cond_1

    .line 243
    add-int/lit8 v1, v1, 0x1

    .line 244
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v2

    add-int/2addr v0, v2

    goto :goto_0

    .line 246
    :cond_1
    iget-object p1, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-static {v1}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 247
    return-void

    .line 239
    :cond_2
    :goto_1
    return-void
.end method

.method public updateStatusBar()V
    .locals 11

    .line 422
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    if-eqz v0, :cond_9

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_6

    .line 423
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 424
    nop

    .line 425
    const/4 v1, 0x0

    const/4 v2, 0x1

    const/4 v3, 0x0

    const/4 v4, 0x1

    :goto_0
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v5

    const/16 v6, 0xa

    if-ge v3, v5, :cond_2

    .line 426
    invoke-virtual {v0, v3}, Ljava/lang/String;->charAt(I)C

    move-result v5

    if-ne v5, v6, :cond_1

    add-int/lit8 v4, v4, 0x1

    .line 425
    :cond_1
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 429
    :cond_2
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v3

    .line 430
    nop

    .line 431
    nop

    .line 432
    const/4 v5, 0x0

    const/4 v7, 0x1

    const/4 v8, 0x1

    :goto_1
    if-ge v5, v3, :cond_4

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v9

    if-ge v5, v9, :cond_4

    .line 433
    invoke-virtual {v0, v5}, Ljava/lang/String;->charAt(I)C

    move-result v9

    if-ne v9, v6, :cond_3

    .line 434
    add-int/lit8 v8, v8, 0x1

    .line 435
    const/4 v7, 0x1

    goto :goto_2

    .line 437
    :cond_3
    add-int/lit8 v7, v7, 0x1

    .line 432
    :goto_2
    add-int/lit8 v5, v5, 0x1

    goto :goto_1

    .line 441
    :cond_4
    nop

    .line 442
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_5

    .line 443
    new-instance v0, Ljava/io/File;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-direct {v0, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 444
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_5

    invoke-virtual {v0}, Ljava/io/File;->length()J

    move-result-wide v5

    goto :goto_3

    .line 448
    :cond_5
    const-wide/16 v5, 0x0

    :goto_3
    const-wide/32 v9, 0x100000

    cmp-long v0, v5, v9

    if-lez v0, :cond_6

    .line 449
    long-to-double v5, v5

    const-wide/high16 v9, 0x4130000000000000L    # 1048576.0

    invoke-static {v5, v6}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr v5, v9

    invoke-static {v5, v6}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v0

    new-array v2, v2, [Ljava/lang/Object;

    aput-object v0, v2, v1

    const-string v0, "%.1f MB"

    invoke-static {v0, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    goto :goto_4

    .line 450
    :cond_6
    const-wide/16 v9, 0x400

    cmp-long v0, v5, v9

    if-lez v0, :cond_7

    .line 451
    long-to-double v5, v5

    const-wide/high16 v9, 0x4090000000000000L    # 1024.0

    invoke-static {v5, v6}, Ljava/lang/Double;->isNaN(D)Z

    div-double/2addr v5, v9

    invoke-static {v5, v6}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v0

    new-array v2, v2, [Ljava/lang/Object;

    aput-object v0, v2, v1

    const-string v0, "%.1f KB"

    invoke-static {v0, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    goto :goto_4

    .line 453
    :cond_7
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, v5, v6}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " B"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 456
    :goto_4
    iget-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    if-eqz v1, :cond_8

    const-string v1, " [Modified]"

    goto :goto_5

    :cond_8
    const-string v1, ""

    .line 457
    :goto_5
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Ln "

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, ", Col "

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v5, "  |  "

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, " lines  |  "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 458
    return-void

    .line 422
    :cond_9
    :goto_6
    return-void
.end method

.method public zoomIn()V
    .locals 2

    .line 300
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x42200000    # 40.0f

    cmpg-float v0, v0, v1

    if-gez v0, :cond_2

    .line 301
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x40000000    # 2.0f

    add-float/2addr v0, v1

    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    .line 302
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setTextSize(F)V

    .line 303
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    .line 304
    :cond_1
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 306
    :cond_2
    return-void
.end method

.method public zoomOut()V
    .locals 2

    .line 310
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x41000000    # 8.0f

    cmpl-float v0, v0, v1

    if-lez v0, :cond_2

    .line 311
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x40000000    # 2.0f

    sub-float/2addr v0, v1

    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    .line 312
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setTextSize(F)V

    .line 313
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    .line 314
    :cond_1
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 316
    :cond_2
    return-void
.end method
