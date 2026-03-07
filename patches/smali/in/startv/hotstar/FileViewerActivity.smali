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

.field public isUndoRedo:Z

.field public lineNumberView:Landroid/widget/TextView;

.field public matchCase:Z

.field public matchCountText:Landroid/widget/TextView;

.field public redoBtn:Landroid/widget/TextView;

.field public redoStack:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public replaceInput:Landroid/widget/EditText;

.field public searchContainer:Landroid/widget/LinearLayout;

.field public searchInput:Landroid/widget/EditText;

.field public statusText:Landroid/widget/TextView;

.field public toggleCaseBtn:Landroid/widget/TextView;

.field public toggleRegexBtn:Landroid/widget/TextView;

.field public toggleWordBtn:Landroid/widget/TextView;

.field public undoBtn:Landroid/widget/TextView;

.field public undoSaveRunnable:Ljava/lang/Runnable;

.field public undoStack:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public useRegex:Z

.field public wholeWord:Z


# direct methods
.method static constructor <clinit>()V
    .locals 3

    .line 108
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

    .line 90
    const/4 v0, 0x0

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    .line 91
    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    .line 92
    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    .line 95
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    .line 96
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    iput-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    .line 97
    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    return-void
.end method

.method public static readFileContent(Ljava/lang/String;)Ljava/lang/String;
    .locals 9

    .line 118
    const/4 v0, 0x0

    :try_start_0
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 119
    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_0

    return-object v0

    .line 120
    :cond_0
    invoke-virtual {v1}, Ljava/io/File;->length()J

    move-result-wide v2

    .line 121
    const-wide/32 v4, 0x3200000

    cmp-long p0, v2, v4

    if-lez p0, :cond_1

    return-object v0

    .line 123
    :cond_1
    new-instance p0, Ljava/io/FileInputStream;

    invoke-direct {p0, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 124
    long-to-int v3, v2

    const/16 v2, 0x2000

    invoke-static {v3, v2}, Ljava/lang/Math;->min(II)I

    move-result v3

    new-array v3, v3, [B

    .line 125
    invoke-virtual {p0, v3}, Ljava/io/FileInputStream;->read([B)I

    move-result v4

    .line 128
    const/4 v5, 0x0

    if-lez v4, :cond_4

    .line 129
    nop

    .line 130
    const/4 v6, 0x0

    const/4 v7, 0x0

    :goto_0
    if-ge v6, v4, :cond_3

    .line 131
    aget-byte v8, v3, v6

    if-nez v8, :cond_2

    add-int/lit8 v7, v7, 0x1

    .line 130
    :cond_2
    add-int/lit8 v6, v6, 0x1

    goto :goto_0

    .line 133
    :cond_3
    div-int/lit8 v4, v4, 0xa

    if-le v7, v4, :cond_4

    .line 134
    invoke-virtual {p0}, Ljava/io/FileInputStream;->close()V

    .line 135
    return-object v0

    .line 138
    :cond_4
    invoke-virtual {p0}, Ljava/io/FileInputStream;->close()V

    .line 141
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    .line 142
    new-instance v3, Ljava/io/BufferedReader;

    new-instance v4, Ljava/io/InputStreamReader;

    new-instance v6, Ljava/io/FileInputStream;

    invoke-direct {v6, v1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    const-string v1, "UTF-8"

    invoke-direct {v4, v6, v1}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    invoke-direct {v3, v4}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    .line 143
    new-array v1, v2, [C

    .line 145
    :goto_1
    invoke-virtual {v3, v1}, Ljava/io/BufferedReader;->read([C)I

    move-result v2

    const/4 v4, -0x1

    if-eq v2, v4, :cond_5

    .line 146
    invoke-virtual {p0, v1, v5, v2}, Ljava/lang/StringBuilder;->append([CII)Ljava/lang/StringBuilder;

    goto :goto_1

    .line 148
    :cond_5
    invoke-virtual {v3}, Ljava/io/BufferedReader;->close()V

    .line 149
    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object p0

    .line 150
    :catch_0
    move-exception p0

    .line 151
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

    .line 152
    return-object v0
.end method

.method public static writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z
    .locals 2

    .line 159
    :try_start_0
    new-instance v0, Ljava/io/BufferedWriter;

    new-instance v1, Ljava/io/FileWriter;

    invoke-direct {v1, p0}, Ljava/io/FileWriter;-><init>(Ljava/lang/String;)V

    invoke-direct {v0, v1}, Ljava/io/BufferedWriter;-><init>(Ljava/io/Writer;)V

    .line 160
    invoke-virtual {v0, p1}, Ljava/io/BufferedWriter;->write(Ljava/lang/String;)V

    .line 161
    invoke-virtual {v0}, Ljava/io/BufferedWriter;->flush()V

    .line 162
    invoke-virtual {v0}, Ljava/io/BufferedWriter;->close()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 163
    const/4 p0, 0x1

    return p0

    .line 164
    :catch_0
    move-exception p0

    .line 165
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

    .line 166
    const/4 p0, 0x0

    return p0
.end method


# virtual methods
.method public animateEntrance(Landroid/view/View;I)V
    .locals 5

    .line 714
    const/high16 v0, 0x3f800000    # 1.0f

    const/4 v1, 0x0

    :try_start_0
    invoke-virtual {p1, v1}, Landroid/view/View;->setAlpha(F)V

    .line 715
    const/16 v2, 0xc

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v2

    int-to-float v2, v2

    invoke-virtual {p1, v2}, Landroid/view/View;->setTranslationY(F)V

    .line 716
    invoke-virtual {p1}, Landroid/view/View;->animate()Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 717
    invoke-virtual {v2, v0}, Landroid/view/ViewPropertyAnimator;->alpha(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 718
    invoke-virtual {v2, v1}, Landroid/view/ViewPropertyAnimator;->translationY(F)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    .line 719
    const-wide/16 v3, 0x12c

    invoke-virtual {v2, v3, v4}, Landroid/view/ViewPropertyAnimator;->setDuration(J)Landroid/view/ViewPropertyAnimator;

    move-result-object v2

    int-to-long v3, p2

    .line 720
    invoke-virtual {v2, v3, v4}, Landroid/view/ViewPropertyAnimator;->setStartDelay(J)Landroid/view/ViewPropertyAnimator;

    move-result-object p2

    new-instance v2, Landroid/view/animation/DecelerateInterpolator;

    invoke-direct {v2}, Landroid/view/animation/DecelerateInterpolator;-><init>()V

    .line 721
    invoke-virtual {p2, v2}, Landroid/view/ViewPropertyAnimator;->setInterpolator(Landroid/animation/TimeInterpolator;)Landroid/view/ViewPropertyAnimator;

    move-result-object p2

    .line 722
    invoke-virtual {p2}, Landroid/view/ViewPropertyAnimator;->start()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 726
    goto :goto_0

    .line 723
    :catch_0
    move-exception p2

    .line 724
    invoke-virtual {p1, v0}, Landroid/view/View;->setAlpha(F)V

    .line 725
    invoke-virtual {p1, v1}, Landroid/view/View;->setTranslationY(F)V

    .line 727
    :goto_0
    return-void
.end method

.method public applySyntaxHighlighting()V
    .locals 7

    .line 410
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_c

    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightEnabled:Z

    if-nez v0, :cond_0

    goto/16 :goto_a

    .line 411
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    .line 412
    if-nez v0, :cond_1

    return-void

    .line 413
    :cond_1
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 414
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    const v3, 0x249f0

    if-le v2, v3, :cond_2

    return-void

    .line 417
    :cond_2
    invoke-interface {v0}, Landroid/text/Editable;->length()I

    move-result v2

    const-class v3, Landroid/text/style/ForegroundColorSpan;

    const/4 v4, 0x0

    invoke-interface {v0, v4, v2, v3}, Landroid/text/Editable;->getSpans(IILjava/lang/Class;)[Ljava/lang/Object;

    move-result-object v2

    check-cast v2, [Landroid/text/style/ForegroundColorSpan;

    .line 418
    array-length v3, v2

    :goto_0
    if-ge v4, v3, :cond_3

    aget-object v5, v2, v4

    .line 419
    invoke-interface {v0, v5}, Landroid/text/Editable;->removeSpan(Ljava/lang/Object;)V

    .line 418
    add-int/lit8 v4, v4, 0x1

    goto :goto_0

    .line 424
    :cond_3
    :try_start_0
    const-string v2, "(?m)^\\s*#.*$"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 425
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 426
    :goto_1
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    const/16 v4, 0x21

    if-eqz v3, :cond_4

    .line 427
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x9566ab

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 428
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 427
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_1

    .line 432
    :cond_4
    const-string v2, "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\""

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 433
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 434
    :goto_2
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_5

    .line 435
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x316e88

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 436
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 435
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_2

    .line 440
    :cond_5
    const-string v2, "(?m)^\\s*\\.(class|method|field|end|super|source|locals|line|param|annotation|registers|implements|prologue|enum|subannotation)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 441
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 442
    :goto_3
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_6

    .line 443
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x3a7940

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 444
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 443
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_3

    .line 448
    :cond_6
    const-string v2, "\\b(invoke-(?:virtual|static|direct|super|interface|polymorphic)(?:/range)?|move-?(?:result)?(?:-object|-wide|-exception)?(?:/(?:from16|16))?|const(?:-string|-class|/(?:high16|4|16))?(?:/jumbo)?|return(?:-void|-object|-wide)?|if-(?:eq|ne|lt|ge|gt|le|eqz|nez|ltz|gez|gtz|lez)|goto(?:/(?:16|32))?|new-instance|new-array|check-cast|instance-of|throw|monitor-(?:enter|exit)|sget(?:-object|-boolean|-wide|-byte|-short|-char)?|sput(?:-object|-boolean|-wide|-byte|-short|-char)?|iget(?:-object|-boolean|-wide|-byte|-short|-char)?|iput(?:-object|-boolean|-wide|-byte|-short|-char)?|aget(?:-object|-boolean|-wide|-byte|-short|-char)?|aput(?:-object|-boolean|-wide|-byte|-short|-char)?|filled-new-array(?:/range)?|array-length|nop|packed-switch|sparse-switch|fill-array-data|add-int|sub-int|mul-int|div-int|rem-int|and-int|or-int|xor-int|shl-int|shr-int|ushr-int|neg-int|not-int|int-to-long|int-to-float|int-to-double|long-to-int|long-to-float|long-to-double|float-to-int|float-to-long|float-to-double|double-to-int|double-to-long|double-to-float|int-to-byte|int-to-char|int-to-short|add-long|sub-long|mul-long|div-long|cmp-long|cmpl-float|cmpg-float|cmpl-double|cmpg-double|add-float|sub-float|mul-float|div-float|add-double|sub-double|mul-double|div-double)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 449
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 450
    :goto_4
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_7

    .line 451
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0xa9632a

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 452
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 451
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_4

    .line 456
    :cond_7
    const-string v2, "L[a-zA-Z][a-zA-Z0-9_/\\$]*;"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 457
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 458
    :goto_5
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_8

    .line 459
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0xb13650

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 460
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 459
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_5

    .line 464
    :cond_8
    const-string v2, "\\b(?:0x[0-9a-fA-F]+|-?\\d+(?:\\.\\d+)?)\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 465
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 466
    :goto_6
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_9

    .line 467
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x4a3158

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 468
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 467
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_6

    .line 472
    :cond_9
    const-string v2, ":[a-zA-Z_][a-zA-Z0-9_]*"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 473
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v2

    .line 474
    :goto_7
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->find()Z

    move-result v3

    if-eqz v3, :cond_a

    .line 475
    new-instance v3, Landroid/text/style/ForegroundColorSpan;

    const v5, -0x232356

    invoke-direct {v3, v5}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 476
    invoke-virtual {v2}, Ljava/util/regex/Matcher;->start()I

    move-result v5

    invoke-virtual {v2}, Ljava/util/regex/Matcher;->end()I

    move-result v6

    .line 475
    invoke-interface {v0, v3, v5, v6, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V

    goto :goto_7

    .line 480
    :cond_a
    const-string v2, "\\b[vp]\\d{1,2}\\b"

    invoke-static {v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;)Ljava/util/regex/Pattern;

    move-result-object v2

    .line 481
    invoke-virtual {v2, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v1

    .line 482
    :goto_8
    invoke-virtual {v1}, Ljava/util/regex/Matcher;->find()Z

    move-result v2

    if-eqz v2, :cond_b

    .line 483
    new-instance v2, Landroid/text/style/ForegroundColorSpan;

    const v3, -0x632302

    invoke-direct {v2, v3}, Landroid/text/style/ForegroundColorSpan;-><init>(I)V

    .line 484
    invoke-virtual {v1}, Ljava/util/regex/Matcher;->start()I

    move-result v3

    invoke-virtual {v1}, Ljava/util/regex/Matcher;->end()I

    move-result v5

    .line 483
    invoke-interface {v0, v2, v3, v5, v4}, Landroid/text/Editable;->setSpan(Ljava/lang/Object;III)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_8

    .line 488
    :cond_b
    goto :goto_9

    .line 486
    :catch_0
    move-exception v0

    .line 487
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

    .line 489
    :goto_9
    return-void

    .line 410
    :cond_c
    :goto_a
    return-void
.end method

.method public buildSearchPattern()Ljava/util/regex/Pattern;
    .locals 4

    .line 533
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return-object v1

    .line 534
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 535
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_1

    return-object v1

    .line 538
    :cond_1
    iget-boolean v2, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    if-eqz v2, :cond_2

    .line 539
    goto :goto_0

    .line 541
    :cond_2
    invoke-static {v0}, Ljava/util/regex/Pattern;->quote(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 544
    :goto_0
    iget-boolean v2, p0, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    if-eqz v2, :cond_3

    .line 545
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "\\b"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 548
    :cond_3
    nop

    .line 549
    iget-boolean v2, p0, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    if-nez v2, :cond_4

    .line 550
    const/16 v2, 0xa

    goto :goto_1

    .line 549
    :cond_4
    const/16 v2, 0x8

    .line 554
    :goto_1
    :try_start_0
    invoke-static {v0, v2}, Ljava/util/regex/Pattern;->compile(Ljava/lang/String;I)Ljava/util/regex/Pattern;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    .line 555
    :catch_0
    move-exception v0

    .line 556
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v0

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Invalid pattern: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const/4 v2, 0x0

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 557
    return-object v1
.end method

.method public createSymbolButton(Ljava/lang/String;)Landroid/widget/TextView;
    .locals 7

    .line 662
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 663
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

    .line 664
    const v2, -0x333334

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextColor(I)V

    .line 665
    const/high16 v2, 0x41800000    # 16.0f

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 666
    const/16 v2, 0x11

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setGravity(I)V

    .line 667
    sget-object v2, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 669
    const/16 v2, 0xe

    invoke-virtual {p0, v2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v2

    .line 670
    const/16 v3, 0x8

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v3

    .line 671
    invoke-virtual {v0, v2, v3, v2, v3}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 673
    new-instance v2, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v2}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 674
    const/4 v3, 0x4

    invoke-virtual {p0, v3}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    int-to-float v4, v4

    invoke-virtual {v2, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 675
    const v4, -0xc3c3c4

    invoke-virtual {v2, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 676
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 679
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v4, -0x2

    invoke-direct {v2, v4, v4}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 681
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

    .line 682
    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 685
    invoke-virtual {p1, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 686
    const-string p1, "    "

    goto :goto_1

    .line 688
    :cond_1
    nop

    .line 691
    :goto_1
    new-instance v1, Lin/startv/hotstar/FileViewerActivity$1;

    invoke-direct {v1, p0, p1}, Lin/startv/hotstar/FileViewerActivity$1;-><init>(Lin/startv/hotstar/FileViewerActivity;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 703
    return-object v0
.end method

.method public createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;
    .locals 2

    .line 642
    new-instance v0, Landroid/widget/TextView;

    invoke-direct {v0, p0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 643
    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 644
    const/4 p1, -0x1

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTextColor(I)V

    .line 645
    invoke-virtual {v0, p2}, Landroid/widget/TextView;->setTextSize(F)V

    .line 646
    const/16 p1, 0x11

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setGravity(I)V

    .line 648
    const/16 p1, 0xc

    invoke-virtual {p0, p1}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p1

    .line 649
    const/16 p2, 0x8

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v1

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p2

    invoke-virtual {v0, p1, v1, p1, p2}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 652
    new-instance p1, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {p1}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 653
    const/4 p2, 0x6

    invoke-virtual {p0, p2}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result p2

    int-to-float p2, p2

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 654
    const/4 p2, 0x0

    invoke-virtual {p1, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 655
    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 657
    return-object v0
.end method

.method public doReplace()V
    .locals 5

    .line 307
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_2

    .line 308
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->buildSearchPattern()Ljava/util/regex/Pattern;

    move-result-object v0

    .line 309
    if-nez v0, :cond_1

    return-void

    .line 310
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 312
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v2

    .line 313
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getSelectionEnd()I

    move-result v3

    .line 314
    if-ltz v2, :cond_4

    if-le v3, v2, :cond_4

    .line 315
    iget-object v4, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v4}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4, v2, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    .line 316
    invoke-virtual {v0, v4}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 317
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->matches()Z

    move-result v4

    if-eqz v4, :cond_3

    .line 318
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->saveUndoState()V

    .line 320
    iget-boolean v4, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    if-eqz v4, :cond_2

    .line 321
    invoke-virtual {v0, v1}, Ljava/util/regex/Matcher;->replaceFirst(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    goto :goto_0

    .line 323
    :cond_2
    nop

    .line 325
    :goto_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-interface {v0, v2, v3, v1}, Landroid/text/Editable;->replace(IILjava/lang/CharSequence;)Landroid/text/Editable;

    .line 326
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    .line 328
    :cond_3
    goto :goto_1

    .line 329
    :cond_4
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->findNext()V

    .line 331
    :goto_1
    return-void

    .line 307
    :cond_5
    :goto_2
    return-void
.end method

.method public doReplaceAll()V
    .locals 6

    .line 335
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_3

    .line 336
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->buildSearchPattern()Ljava/util/regex/Pattern;

    move-result-object v0

    .line 337
    if-nez v0, :cond_1

    return-void

    .line 338
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 341
    const/4 v2, 0x0

    :try_start_0
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    .line 342
    invoke-virtual {v0, v3}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 344
    nop

    .line 345
    new-instance v3, Ljava/lang/StringBuffer;

    invoke-direct {v3}, Ljava/lang/StringBuffer;-><init>()V

    const/4 v4, 0x0

    .line 346
    :goto_0
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v5

    if-eqz v5, :cond_3

    .line 347
    add-int/lit8 v4, v4, 0x1

    .line 348
    iget-boolean v5, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    if-eqz v5, :cond_2

    .line 349
    invoke-virtual {v0, v3, v1}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    goto :goto_0

    .line 351
    :cond_2
    invoke-static {v1}, Ljava/util/regex/Matcher;->quoteReplacement(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v0, v3, v5}, Ljava/util/regex/Matcher;->appendReplacement(Ljava/lang/StringBuffer;Ljava/lang/String;)Ljava/util/regex/Matcher;

    goto :goto_0

    .line 355
    :cond_3
    if-lez v4, :cond_4

    .line 356
    invoke-virtual {v0, v3}, Ljava/util/regex/Matcher;->appendTail(Ljava/lang/StringBuffer;)Ljava/lang/StringBuffer;

    .line 357
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->saveUndoState()V

    .line 358
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 359
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Replaced "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " occurrences"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    goto :goto_1

    .line 361
    :cond_4
    const-string v0, "No matches found"

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 366
    :goto_1
    goto :goto_2

    .line 363
    :catch_0
    move-exception v0

    .line 364
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

    .line 365
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

    .line 367
    :goto_2
    return-void

    .line 335
    :cond_5
    :goto_3
    return-void
.end method

.method public dpToPx(I)I
    .locals 1

    .line 708
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

    .line 207
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_7

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_2

    .line 208
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->buildSearchPattern()Ljava/util/regex/Pattern;

    move-result-object v0

    .line 209
    if-nez v0, :cond_1

    return-void

    .line 211
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 212
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionEnd()I

    move-result v2

    .line 213
    const/4 v3, 0x0

    if-gez v2, :cond_2

    const/4 v2, 0x0

    .line 215
    :cond_2
    invoke-virtual {v0, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 216
    nop

    .line 218
    invoke-virtual {v0, v2}, Ljava/util/regex/Matcher;->find(I)Z

    move-result v1

    const/4 v4, 0x1

    if-eqz v1, :cond_3

    .line 219
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v2

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->end()I

    move-result v0

    invoke-virtual {v1, v2, v0}, Landroid/widget/EditText;->setSelection(II)V

    .line 220
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->requestFocus()Z

    .line 221
    goto :goto_0

    .line 222
    :cond_3
    if-lez v2, :cond_4

    .line 224
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->reset()Ljava/util/regex/Matcher;

    .line 225
    invoke-virtual {v0, v3}, Ljava/util/regex/Matcher;->find(I)Z

    move-result v1

    if-eqz v1, :cond_4

    .line 226
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v2

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->end()I

    move-result v0

    invoke-virtual {v1, v2, v0}, Landroid/widget/EditText;->setSelection(II)V

    .line 227
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->requestFocus()Z

    .line 228
    goto :goto_0

    .line 232
    :cond_4
    const/4 v4, 0x0

    :goto_0
    if-eqz v4, :cond_5

    .line 233
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount()V

    goto :goto_1

    .line 235
    :cond_5
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-eqz v0, :cond_6

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v1, "0"

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 236
    :cond_6
    const-string v0, "Not found"

    invoke-static {p0, v0, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 238
    :goto_1
    return-void

    .line 207
    :cond_7
    :goto_2
    return-void
.end method

.method public findPrev()V
    .locals 5

    .line 242
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_8

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_4

    .line 243
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->buildSearchPattern()Ljava/util/regex/Pattern;

    move-result-object v0

    .line 244
    if-nez v0, :cond_1

    return-void

    .line 246
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 247
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v2

    .line 248
    if-gez v2, :cond_2

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    .line 250
    :cond_2
    invoke-virtual {v0, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 251
    nop

    .line 252
    const/4 v1, -0x1

    const/4 v3, -0x1

    .line 254
    :goto_0
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v4

    if-eqz v4, :cond_4

    .line 255
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v4

    if-lt v4, v2, :cond_3

    goto :goto_1

    .line 256
    :cond_3
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v1

    .line 257
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->end()I

    move-result v3

    goto :goto_0

    .line 260
    :cond_4
    :goto_1
    if-gez v1, :cond_5

    .line 262
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->reset()Ljava/util/regex/Matcher;

    .line 263
    :goto_2
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v2

    if-eqz v2, :cond_5

    .line 264
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v1

    .line 265
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->end()I

    move-result v3

    goto :goto_2

    .line 269
    :cond_5
    if-ltz v1, :cond_6

    .line 270
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0, v1, v3}, Landroid/widget/EditText;->setSelection(II)V

    .line 271
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->requestFocus()Z

    .line 272
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount()V

    goto :goto_3

    .line 274
    :cond_6
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-eqz v0, :cond_7

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v1, "0"

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 275
    :cond_7
    const-string v0, "Not found"

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 277
    :goto_3
    return-void

    .line 242
    :cond_8
    :goto_4
    return-void
.end method

.method public getFileName()Ljava/lang/String;
    .locals 2

    .line 172
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-nez v0, :cond_0

    const-string v0, "Untitled"

    return-object v0

    .line 173
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    const/16 v1, 0x2f

    invoke-virtual {v0, v1}, Ljava/lang/String;->lastIndexOf(I)I

    move-result v0

    .line 174
    if-ltz v0, :cond_1

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    add-int/lit8 v1, v1, -0x1

    if-ge v0, v1, :cond_1

    .line 175
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    add-int/lit8 v0, v0, 0x1

    invoke-virtual {v1, v0}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 177
    :cond_1
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    return-object v0
.end method

.method public onBackPressed()V
    .locals 3

    .line 1153
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    if-eqz v0, :cond_0

    .line 1154
    new-instance v0, Landroid/app/AlertDialog$Builder;

    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    .line 1155
    const-string v1, "Unsaved Changes"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 1156
    const-string v1, "You have unsaved changes. Save before closing?"

    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lin/startv/hotstar/FileViewerActivity$3;

    invoke-direct {v1, p0}, Lin/startv/hotstar/FileViewerActivity$3;-><init>(Lin/startv/hotstar/FileViewerActivity;)V

    .line 1157
    const-string v2, "Save"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    new-instance v1, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;

    invoke-direct {v1, p0, p0}, Lin/startv/hotstar/FileViewerActivity$DiscardClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    .line 1163
    const-string v2, "Discard"

    invoke-virtual {v0, v2, v1}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 1164
    const-string v1, "Cancel"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNeutralButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v0

    .line 1165
    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto :goto_0

    .line 1167
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->finish()V

    .line 1169
    :goto_0
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .locals 16

    .line 732
    move-object/from16 v1, p0

    invoke-super/range {p0 .. p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    .line 736
    const/4 v2, 0x1

    :try_start_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x15

    const v4, -0xdadada

    if-lt v0, v3, :cond_0

    .line 737
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/view/Window;->setStatusBarColor(I)V

    .line 739
    :cond_0
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1c

    if-lt v0, v3, :cond_1

    .line 740
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    invoke-virtual {v0, v4}, Landroid/view/Window;->setNavigationBarColor(I)V

    .line 744
    :cond_1
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getWindow()Landroid/view/Window;

    move-result-object v0

    const/16 v3, 0x10

    invoke-virtual {v0, v3}, Landroid/view/Window;->setSoftInputMode(I)V

    .line 747
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getIntent()Landroid/content/Intent;

    move-result-object v0

    const-string v5, "filePath"

    invoke-virtual {v0, v5}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iput-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    .line 750
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 751
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 752
    const v5, -0xe1e1e2

    invoke-virtual {v0, v5}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 753
    invoke-virtual {v0, v2}, Landroid/widget/LinearLayout;->setFitsSystemWindows(Z)V

    .line 756
    new-instance v6, Landroid/widget/LinearLayout;

    invoke-direct {v6, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 757
    const/4 v7, 0x0

    invoke-virtual {v6, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 758
    invoke-virtual {v6, v3}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 759
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 760
    const/16 v8, 0x8

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v6, v9, v10, v11, v12}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 763
    const-string v9, "\u2190"

    const/high16 v10, 0x41b00000    # 22.0f

    invoke-virtual {v1, v9, v10}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v9

    .line 764
    new-instance v10, Lin/startv/hotstar/FileViewerActivity$BackClickListener;

    invoke-direct {v10, v1, v1}, Lin/startv/hotstar/FileViewerActivity$BackClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 765
    invoke-virtual {v6, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 768
    new-instance v9, Landroid/widget/TextView;

    invoke-direct {v9, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 769
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->getFileName()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 770
    const/4 v10, -0x1

    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setTextColor(I)V

    .line 771
    const/high16 v11, 0x41800000    # 16.0f

    invoke-virtual {v9, v11}, Landroid/widget/TextView;->setTextSize(F)V

    .line 772
    sget-object v12, Landroid/graphics/Typeface;->DEFAULT_BOLD:Landroid/graphics/Typeface;

    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 773
    invoke-virtual {v9, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 774
    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    const/4 v13, 0x4

    invoke-virtual {v1, v13}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v14

    invoke-virtual {v9, v12, v7, v14, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 775
    new-instance v12, Landroid/widget/LinearLayout$LayoutParams;

    const/high16 v14, 0x3f800000    # 1.0f

    const/4 v15, -0x2

    invoke-direct {v12, v7, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 776
    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 777
    invoke-virtual {v6, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 780
    const-string v9, "A\u2212"

    invoke-virtual {v1, v9, v11}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v9

    .line 781
    new-instance v12, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v5, 0x7

    invoke-direct {v12, v1, v1, v5}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v9, v12}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 782
    invoke-virtual {v6, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 785
    const-string v5, "A+"

    invoke-virtual {v1, v5, v11}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    .line 786
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v12, 0x6

    invoke-direct {v9, v1, v1, v12}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 787
    invoke-virtual {v6, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 790
    const-string v5, "\u21b6"

    const/high16 v9, 0x41a00000    # 20.0f

    invoke-virtual {v1, v5, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->undoBtn:Landroid/widget/TextView;

    .line 791
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->undoBtn:Landroid/widget/TextView;

    new-instance v4, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    invoke-direct {v4, v1, v1, v8}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v4}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 792
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->undoBtn:Landroid/widget/TextView;

    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 795
    const-string v4, "\u21b7"

    invoke-virtual {v1, v4, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->redoBtn:Landroid/widget/TextView;

    .line 796
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->redoBtn:Landroid/widget/TextView;

    new-instance v5, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/16 v11, 0x9

    invoke-direct {v5, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 797
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->redoBtn:Landroid/widget/TextView;

    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 800
    const-string v4, "\ud83d\udd0d"

    invoke-virtual {v1, v4, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    .line 801
    new-instance v5, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    invoke-direct {v5, v1, v1, v7}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 802
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 805
    const-string v4, "\ud83d\udcbe"

    invoke-virtual {v1, v4, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v4

    .line 806
    new-instance v5, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;

    invoke-direct {v5, v1, v1}, Lin/startv/hotstar/FileViewerActivity$SaveClickListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 807
    invoke-virtual {v6, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 809
    invoke-virtual {v0, v6}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 812
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 813
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v5, v10, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v5}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 814
    const v5, -0xc3c3c4

    invoke-virtual {v4, v5}, Landroid/view/View;->setBackgroundColor(I)V

    .line 815
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 818
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    .line 819
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 820
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const v9, -0xd2d2d3

    invoke-virtual {v4, v9}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V

    .line 821
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v4, v9, v11, v10, v13}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 822
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v4, v8}, Landroid/widget/LinearLayout;->setVisibility(I)V

    .line 825
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 826
    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 827
    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 829
    new-instance v9, Landroid/widget/EditText;

    invoke-direct {v9, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    .line 830
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const-string v10, "Search..."

    invoke-virtual {v9, v10}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 831
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v10, -0xa5a5a6

    invoke-virtual {v9, v10}, Landroid/widget/EditText;->setHintTextColor(I)V

    .line 832
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v11, -0x2b2b2c

    invoke-virtual {v9, v11}, Landroid/widget/EditText;->setTextColor(I)V

    .line 833
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const/high16 v13, 0x41600000    # 14.0f

    invoke-virtual {v9, v13}, Landroid/widget/EditText;->setTextSize(F)V

    .line 834
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 835
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v5}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 836
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v8}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v9, v5, v11, v10, v8}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 837
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    const v8, 0x80001

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 838
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v5, v7, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 839
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v5, v7, v7, v10, v7}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 840
    iget-object v9, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v9, v5}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 841
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 844
    new-instance v5, Landroid/widget/TextView;

    invoke-direct {v5, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    .line 845
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v9, "0"

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 846
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const v9, -0x7a7a7b

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setTextColor(I)V

    .line 847
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const/high16 v10, 0x41400000    # 12.0f

    invoke-virtual {v5, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 848
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v5, v11, v7, v9, v7}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 849
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 852
    const-string v5, "Aa"

    invoke-virtual {v1, v5, v10}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleCaseBtn:Landroid/widget/TextView;

    .line 853
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleCaseBtn:Landroid/widget/TextView;

    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/16 v11, 0xa

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 854
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleCaseBtn:Landroid/widget/TextView;

    iget-boolean v9, v1, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    invoke-virtual {v1, v5, v9}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 855
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleCaseBtn:Landroid/widget/TextView;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 858
    const-string v5, "W"

    invoke-virtual {v1, v5, v10}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleWordBtn:Landroid/widget/TextView;

    .line 859
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleWordBtn:Landroid/widget/TextView;

    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/16 v11, 0xb

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 860
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleWordBtn:Landroid/widget/TextView;

    iget-boolean v9, v1, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    invoke-virtual {v1, v5, v9}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 861
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleWordBtn:Landroid/widget/TextView;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 864
    const-string v5, ".*"

    invoke-virtual {v1, v5, v10}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleRegexBtn:Landroid/widget/TextView;

    .line 865
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleRegexBtn:Landroid/widget/TextView;

    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/16 v11, 0xc

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 866
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleRegexBtn:Landroid/widget/TextView;

    iget-boolean v9, v1, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    invoke-virtual {v1, v5, v9}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 867
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->toggleRegexBtn:Landroid/widget/TextView;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 870
    const-string v5, "\u25b2"

    invoke-virtual {v1, v5, v13}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    .line 871
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v11, 0x2

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 872
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 875
    const-string v5, "\u25bc"

    invoke-virtual {v1, v5, v13}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    .line 876
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    invoke-direct {v9, v1, v1, v2}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 877
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 880
    const-string v5, "\u2715"

    const/high16 v9, 0x41800000    # 16.0f

    invoke-virtual {v1, v5, v9}, Lin/startv/hotstar/FileViewerActivity;->createToolbarButton(Ljava/lang/String;F)Landroid/widget/TextView;

    move-result-object v5

    .line 881
    new-instance v9, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v11, 0x5

    invoke-direct {v9, v1, v1, v11}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v5, v9}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 882
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 884
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v5, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 887
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 888
    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 889
    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 890
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v4, v7, v5, v7, v7}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    .line 892
    new-instance v5, Landroid/widget/EditText;

    invoke-direct {v5, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    .line 893
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const-string v9, "Replace..."

    invoke-virtual {v5, v9}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V

    .line 894
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0xa5a5a6

    invoke-virtual {v5, v9}, Landroid/widget/EditText;->setHintTextColor(I)V

    .line 895
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0x2b2b2c

    invoke-virtual {v5, v9}, Landroid/widget/EditText;->setTextColor(I)V

    .line 896
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v5, v13}, Landroid/widget/EditText;->setTextSize(F)V

    .line 897
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v5, v2}, Landroid/widget/EditText;->setSingleLine(Z)V

    .line 898
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const v9, -0xc3c3c4

    invoke-virtual {v5, v9}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 899
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v3

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v5, v13, v3, v11, v9}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 900
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v3, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 901
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v3, v7, v15, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 902
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v3, v7, v7, v5, v7}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 903
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v5, v3}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 904
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->replaceInput:Landroid/widget/EditText;

    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 907
    new-instance v3, Landroid/widget/TextView;

    invoke-direct {v3, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 908
    const-string v5, "Replace"

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 909
    const/4 v5, -0x1

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 910
    invoke-virtual {v3, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 911
    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v3, v5, v8, v11, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 912
    new-instance v5, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v5}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 913
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    int-to-float v8, v8

    invoke-virtual {v5, v8}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 914
    const v8, -0xff872c

    invoke-virtual {v5, v8}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 915
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 916
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v5, v15, v15}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 918
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v5, v7, v7, v8, v7}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V

    .line 919
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 920
    new-instance v5, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v8, 0x3

    invoke-direct {v5, v1, v1, v8}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 921
    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 924
    new-instance v3, Landroid/widget/TextView;

    invoke-direct {v3, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 925
    const-string v5, "All"

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 926
    const/4 v5, -0x1

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 927
    invoke-virtual {v3, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 928
    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v12}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v3, v5, v8, v11, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 929
    new-instance v5, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v5}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 930
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    int-to-float v8, v8

    invoke-virtual {v5, v8}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 931
    const v8, -0xff872c

    invoke-virtual {v5, v8}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 932
    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 933
    new-instance v5, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;

    const/4 v9, 0x4

    invoke-direct {v5, v1, v1, v9}, Lin/startv/hotstar/FileViewerActivity$SearchActionListener;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;I)V

    invoke-virtual {v3, v5}, Landroid/widget/TextView;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 934
    invoke-virtual {v4, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 936
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v3, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 937
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 940
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 941
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v5, -0x1

    invoke-direct {v4, v5, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 942
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 943
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 946
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 947
    const v4, -0xdadada

    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->setBackgroundColor(I)V

    .line 948
    invoke-virtual {v3, v7}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 949
    const/16 v4, 0xc

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    invoke-virtual {v1, v4}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v11

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v3, v5, v8, v11, v4}, Landroid/widget/HorizontalScrollView;->setPadding(IIII)V

    .line 951
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    .line 952
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v5, :cond_2

    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    goto :goto_0

    :cond_2
    const-string v5, ""

    :goto_0
    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 953
    const v5, -0x7a7a7b

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 954
    const/high16 v5, 0x41300000    # 11.0f

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextSize(F)V

    .line 955
    sget-object v5, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 956
    invoke-virtual {v4, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 957
    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 958
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 961
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 962
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v5, -0x1

    invoke-direct {v4, v5, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 963
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 964
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 967
    new-instance v3, Landroid/widget/ScrollView;

    invoke-direct {v3, v1}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V

    iput-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    .line 968
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v3, v2}, Landroid/widget/ScrollView;->setVerticalScrollBarEnabled(Z)V

    .line 969
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v3, v7}, Landroid/widget/ScrollView;->setScrollbarFadingEnabled(Z)V

    .line 970
    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v5, -0x1

    invoke-direct {v3, v5, v7, v14}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V

    .line 972
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v4, v3}, Landroid/widget/ScrollView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 974
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 975
    invoke-virtual {v3, v2}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 976
    invoke-virtual {v3, v2}, Landroid/widget/HorizontalScrollView;->setFillViewport(Z)V

    .line 978
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 979
    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 982
    new-instance v5, Landroid/widget/TextView;

    invoke-direct {v5, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    .line 983
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const v8, -0x7a7a7b

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setTextColor(I)V

    .line 984
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v8, v1, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setTextSize(F)V

    .line 985
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 986
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const/4 v8, 0x5

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setGravity(I)V

    .line 987
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const/16 v9, 0x8

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    const/4 v11, 0x4

    invoke-virtual {v1, v11}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v12

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v13

    invoke-virtual {v1, v11}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v5, v8, v12, v13, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 988
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const v8, -0xe1e1e2

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 989
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    const-string v8, "  1"

    invoke-virtual {v5, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 991
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v5, v7}, Landroid/widget/TextView;->setFocusable(Z)V

    .line 992
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v5, v7}, Landroid/widget/TextView;->setClickable(Z)V

    .line 993
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 996
    new-instance v5, Landroid/view/View;

    invoke-direct {v5, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 997
    new-instance v8, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v9, -0x1

    invoke-direct {v8, v2, v9}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v5, v8}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 998
    const v9, -0xc3c3c4

    invoke-virtual {v5, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 999
    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1002
    new-instance v5, Landroid/widget/EditText;

    invoke-direct {v5, v1}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V

    iput-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    .line 1003
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v9, -0x2b2b2c

    invoke-virtual {v5, v9}, Landroid/widget/EditText;->setTextColor(I)V

    .line 1004
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v8, v1, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setTextSize(F)V

    .line 1005
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V

    .line 1006
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, -0xe1e1e2

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setBackgroundColor(I)V

    .line 1007
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

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

    invoke-virtual {v5, v8, v11, v13, v12}, Landroid/widget/EditText;->setPadding(IIII)V

    .line 1008
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const/16 v8, 0x33

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setGravity(I)V

    .line 1009
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, 0xa0001

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setInputType(I)V

    .line 1012
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v5, v7}, Landroid/widget/EditText;->setHorizontallyScrolling(Z)V

    .line 1013
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v5, v7}, Landroid/widget/EditText;->setVerticalScrollBarEnabled(Z)V

    .line 1016
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    invoke-direct {v5, v15, v15}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    .line 1018
    iput v7, v5, Landroid/widget/LinearLayout$LayoutParams;->width:I

    .line 1019
    iput v14, v5, Landroid/widget/LinearLayout$LayoutParams;->weight:F

    .line 1020
    iget-object v8, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v8, v5}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 1023
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const v8, 0x40569cd6

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->setHighlightColor(I)V

    .line 1026
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    new-instance v8, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;

    invoke-direct {v8, v1, v1}, Lin/startv/hotstar/FileViewerActivity$TextChangeWatcher;-><init>(Lin/startv/hotstar/FileViewerActivity;Lin/startv/hotstar/FileViewerActivity;)V

    invoke-virtual {v5, v8}, Landroid/widget/EditText;->addTextChangedListener(Landroid/text/TextWatcher;)V

    .line 1028
    iget-object v5, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v4, v5}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1030
    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 1031
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v4, v3}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V

    .line 1032
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1035
    new-instance v3, Landroid/view/View;

    invoke-direct {v3, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 1036
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v5, -0x1

    invoke-direct {v4, v5, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 1037
    const v9, -0xc3c3c4

    invoke-virtual {v3, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 1038
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1041
    new-instance v3, Landroid/widget/HorizontalScrollView;

    invoke-direct {v3, v1}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    .line 1042
    const v4, -0xdadada

    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->setBackgroundColor(I)V

    .line 1043
    invoke-virtual {v3, v7}, Landroid/widget/HorizontalScrollView;->setHorizontalScrollBarEnabled(Z)V

    .line 1044
    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v3, v4, v7, v5, v7}, Landroid/widget/HorizontalScrollView;->setPadding(IIII)V

    .line 1046
    new-instance v4, Landroid/widget/LinearLayout;

    invoke-direct {v4, v1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    .line 1047
    invoke-virtual {v4, v7}, Landroid/widget/LinearLayout;->setOrientation(I)V

    .line 1048
    const/16 v12, 0x10

    invoke-virtual {v4, v12}, Landroid/widget/LinearLayout;->setGravity(I)V

    .line 1050
    sget-object v5, Lin/startv/hotstar/FileViewerActivity;->SYMBOLS:[Ljava/lang/String;

    array-length v8, v5

    const/4 v9, 0x0

    :goto_1
    if-ge v9, v8, :cond_3

    aget-object v11, v5, v9

    .line 1051
    invoke-virtual {v1, v11}, Lin/startv/hotstar/FileViewerActivity;->createSymbolButton(Ljava/lang/String;)Landroid/widget/TextView;

    move-result-object v11

    invoke-virtual {v4, v11}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1050
    add-int/lit8 v9, v9, 0x1

    goto :goto_1

    .line 1054
    :cond_3
    invoke-virtual {v3, v4}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V

    .line 1055
    invoke-virtual {v0, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1058
    new-instance v4, Landroid/view/View;

    invoke-direct {v4, v1}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    .line 1059
    new-instance v5, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v9, -0x1

    invoke-direct {v5, v9, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v4, v5}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 1060
    const v9, -0xc3c3c4

    invoke-virtual {v4, v9}, Landroid/view/View;->setBackgroundColor(I)V

    .line 1061
    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1064
    new-instance v4, Landroid/widget/TextView;

    invoke-direct {v4, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    iput-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    .line 1065
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/4 v5, -0x1

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTextColor(I)V

    .line 1066
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v4, v10}, Landroid/widget/TextView;->setTextSize(F)V

    .line 1067
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    sget-object v5, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V

    .line 1068
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const v5, -0xff8534

    invoke-virtual {v4, v5}, Landroid/widget/TextView;->setBackgroundColor(I)V

    .line 1069
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/16 v5, 0xc

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v8

    const/4 v9, 0x4

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v10

    invoke-virtual {v1, v5}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v5

    invoke-virtual {v1, v9}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v9

    invoke-virtual {v4, v8, v10, v5, v9}, Landroid/widget/TextView;->setPadding(IIII)V

    .line 1070
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v4, v2}, Landroid/widget/TextView;->setSingleLine(Z)V

    .line 1071
    iget-object v4, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    invoke-virtual {v0, v4}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    .line 1073
    invoke-virtual {v1, v0}, Lin/startv/hotstar/FileViewerActivity;->setContentView(Landroid/view/View;)V

    .line 1076
    invoke-virtual {v1, v6, v7}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 1077
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editorScroll:Landroid/widget/ScrollView;

    const/16 v4, 0x64

    invoke-virtual {v1, v0, v4}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 1078
    const/16 v0, 0xc8

    invoke-virtual {v1, v3, v0}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 1079
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    const/16 v3, 0xfa

    invoke-virtual {v1, v0, v3}, Lin/startv/hotstar/FileViewerActivity;->animateEntrance(Landroid/view/View;I)V

    .line 1082
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_6

    .line 1083
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-static {v0}, Lin/startv/hotstar/FileViewerActivity;->readFileContent(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 1084
    if-eqz v0, :cond_4

    .line 1085
    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3, v0}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 1086
    iput-boolean v7, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    .line 1089
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    new-instance v3, Lin/startv/hotstar/FileViewerActivity$2;

    invoke-direct {v3, v1}, Lin/startv/hotstar/FileViewerActivity$2;-><init>(Lin/startv/hotstar/FileViewerActivity;)V

    const-wide/16 v4, 0xc8

    invoke-virtual {v0, v3, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    goto :goto_2

    .line 1101
    :cond_4
    new-instance v0, Ljava/io/File;

    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-direct {v0, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 1102
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0

    if-eqz v0, :cond_5

    .line 1103
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const-string v3, "[Binary file - cannot display]"

    invoke-virtual {v0, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 1104
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0, v7}, Landroid/widget/EditText;->setEnabled(Z)V

    .line 1105
    iput-boolean v2, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    goto :goto_2

    .line 1107
    :cond_5
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const-string v3, ""

    invoke-virtual {v0, v3}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 1108
    iput-boolean v7, v1, Lin/startv/hotstar/FileViewerActivity;->isBinary:Z

    .line 1113
    :cond_6
    :goto_2
    iput-boolean v7, v1, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    .line 1114
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 1115
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->updateStatusBar()V

    .line 1118
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_7

    .line 1119
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 1120
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 1121
    iget-object v0, v1, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    iget-object v3, v1, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 1128
    :cond_7
    goto :goto_3

    .line 1124
    :catch_0
    move-exception v0

    .line 1125
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

    .line 1126
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

    .line 1127
    invoke-virtual {v1}, Lin/startv/hotstar/FileViewerActivity;->finish()V

    .line 1129
    :goto_3
    return-void
.end method

.method protected onDestroy()V
    .locals 2

    .line 1135
    :try_start_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    if-eqz v0, :cond_0

    .line 1136
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 1138
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->undoSaveRunnable:Ljava/lang/Runnable;

    if-eqz v0, :cond_1

    .line 1139
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->undoSaveRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 1141
    :cond_1
    const/4 v0, 0x0

    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->handler:Landroid/os/Handler;

    .line 1142
    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->highlightRunnable:Ljava/lang/Runnable;

    .line 1143
    iput-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->undoSaveRunnable:Ljava/lang/Runnable;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 1146
    goto :goto_0

    .line 1144
    :catch_0
    move-exception v0

    .line 1147
    :goto_0
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V

    .line 1148
    return-void
.end method

.method public redo()V
    .locals 4

    .line 578
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    .line 582
    :cond_0
    const/4 v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    .line 583
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 584
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I

    move-result v3

    sub-int/2addr v3, v0

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 585
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2, v0}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 586
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->length()I

    move-result v3

    invoke-static {v0, v3}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-virtual {v2, v0}, Landroid/widget/EditText;->setSelection(I)V

    .line 587
    iput-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    .line 588
    const-string v0, "Redo"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 589
    return-void

    .line 579
    :cond_1
    :goto_0
    const-string v0, "Nothing to redo"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 580
    return-void
.end method

.method public saveFile()V
    .locals 2

    .line 182
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_2

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto :goto_1

    .line 183
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 184
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-static {v1, v0}, Lin/startv/hotstar/FileViewerActivity;->writeFileContent(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v0

    .line 185
    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 186
    iput-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    .line 187
    const-string v0, "Saved successfully"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 188
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateStatusBar()V

    goto :goto_0

    .line 190
    :cond_1
    const-string v0, "Save failed!"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 192
    :goto_0
    return-void

    .line 182
    :cond_2
    :goto_1
    return-void
.end method

.method public saveUndoState()V
    .locals 3

    .line 593
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_3

    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    if-eqz v0, :cond_0

    goto :goto_0

    .line 594
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 595
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v1

    if-lez v1, :cond_1

    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v2}, Ljava/util/ArrayList;->size()I

    move-result v2

    add-int/lit8 v2, v2, -0x1

    invoke-virtual {v1, v2}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    return-void

    .line 596
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 597
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->size()I

    move-result v0

    const/16 v1, 0x1e

    if-le v0, v1, :cond_2

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    .line 598
    :cond_2
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    .line 599
    return-void

    .line 593
    :cond_3
    :goto_0
    return-void
.end method

.method public toggleMatchCase()V
    .locals 2

    .line 615
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    xor-int/lit8 v0, v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    .line 616
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->toggleCaseBtn:Landroid/widget/TextView;

    iget-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->matchCase:Z

    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 617
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_0

    .line 618
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount()V

    .line 620
    :cond_0
    return-void
.end method

.method public toggleRegex()V
    .locals 2

    .line 633
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    xor-int/lit8 v0, v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    .line 634
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->toggleRegexBtn:Landroid/widget/TextView;

    iget-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->useRegex:Z

    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 635
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_0

    .line 636
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount()V

    .line 638
    :cond_0
    return-void
.end method

.method public toggleSearch()V
    .locals 2

    .line 196
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    if-nez v0, :cond_0

    return-void

    .line 197
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    invoke-virtual {v0}, Landroid/widget/LinearLayout;->getVisibility()I

    move-result v0

    if-nez v0, :cond_1

    .line 198
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const/16 v1, 0x8

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setVisibility(I)V

    goto :goto_0

    .line 200
    :cond_1
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchContainer:Landroid/widget/LinearLayout;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Landroid/widget/LinearLayout;->setVisibility(I)V

    .line 201
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->requestFocus()Z

    .line 203
    :goto_0
    return-void
.end method

.method public toggleWholeWord()V
    .locals 2

    .line 624
    iget-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    xor-int/lit8 v0, v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    .line 625
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->toggleWordBtn:Landroid/widget/TextView;

    iget-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->wholeWord:Z

    invoke-virtual {p0, v0, v1}, Lin/startv/hotstar/FileViewerActivity;->updateToggleStyle(Landroid/widget/TextView;Z)V

    .line 626
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->searchInput:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_0

    .line 627
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateMatchCount()V

    .line 629
    :cond_0
    return-void
.end method

.method public undo()V
    .locals 4

    .line 563
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    .line 567
    :cond_0
    const/4 v0, 0x1

    iput-boolean v0, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    .line 568
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->redoStack:Ljava/util/ArrayList;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 569
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->undoStack:Ljava/util/ArrayList;

    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I

    move-result v3

    sub-int/2addr v3, v0

    invoke-virtual {v2, v3}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .line 570
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v2, v0}, Landroid/widget/EditText;->setText(Ljava/lang/CharSequence;)V

    .line 571
    iget-object v2, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->length()I

    move-result v3

    invoke-static {v0, v3}, Ljava/lang/Math;->min(II)I

    move-result v0

    invoke-virtual {v2, v0}, Landroid/widget/EditText;->setSelection(I)V

    .line 572
    iput-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isUndoRedo:Z

    .line 573
    const-string v0, "Undo"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 574
    return-void

    .line 564
    :cond_1
    :goto_0
    const-string v0, "Nothing to undo"

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    .line 565
    return-void
.end method

.method public updateLineNumbers()V
    .locals 9

    .line 391
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_5

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-nez v0, :cond_0

    goto :goto_2

    .line 392
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 393
    nop

    .line 394
    const/4 v1, 0x0

    const/4 v2, 0x1

    const/4 v3, 0x0

    const/4 v4, 0x1

    :goto_0
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v5

    const/16 v6, 0xa

    if-ge v3, v5, :cond_2

    .line 395
    invoke-virtual {v0, v3}, Ljava/lang/String;->charAt(I)C

    move-result v5

    if-ne v5, v6, :cond_1

    add-int/lit8 v4, v4, 0x1

    .line 394
    :cond_1
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 398
    :cond_2
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    .line 399
    invoke-static {v4}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    .line 400
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

    .line 401
    const/4 v5, 0x1

    :goto_1
    if-gt v5, v4, :cond_4

    .line 402
    if-le v5, v2, :cond_3

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    .line 403
    :cond_3
    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    new-array v8, v2, [Ljava/lang/Object;

    aput-object v7, v8, v1

    invoke-static {v3, v8}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 401
    add-int/lit8 v5, v5, 0x1

    goto :goto_1

    .line 405
    :cond_4
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 406
    return-void

    .line 391
    :cond_5
    :goto_2
    return-void
.end method

.method public updateMatchCount()V
    .locals 5

    .line 281
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    if-nez v0, :cond_0

    return-void

    .line 282
    :cond_0
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->buildSearchPattern()Ljava/util/regex/Pattern;

    move-result-object v0

    .line 283
    if-nez v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    const-string v1, "0"

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    return-void

    .line 285
    :cond_1
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    .line 286
    invoke-virtual {v0, v1}, Ljava/util/regex/Pattern;->matcher(Ljava/lang/CharSequence;)Ljava/util/regex/Matcher;

    move-result-object v0

    .line 287
    nop

    .line 288
    nop

    .line 289
    iget-object v1, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v1}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v1

    const/4 v2, 0x0

    const/4 v3, 0x0

    .line 291
    :cond_2
    :goto_0
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->find()Z

    move-result v4

    if-eqz v4, :cond_3

    .line 292
    add-int/lit8 v3, v3, 0x1

    .line 293
    invoke-virtual {v0}, Ljava/util/regex/Matcher;->start()I

    move-result v4

    if-gt v4, v1, :cond_2

    invoke-virtual {v0}, Ljava/util/regex/Matcher;->end()I

    move-result v4

    if-lt v4, v1, :cond_2

    .line 294
    move v2, v3

    goto :goto_0

    .line 298
    :cond_3
    if-lez v2, :cond_4

    .line 299
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "/"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    goto :goto_1

    .line 301
    :cond_4
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->matchCountText:Landroid/widget/TextView;

    invoke-static {v3}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 303
    :goto_1
    return-void
.end method

.method public updateStatusBar()V
    .locals 11

    .line 493
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->statusText:Landroid/widget/TextView;

    if-eqz v0, :cond_9

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-nez v0, :cond_0

    goto/16 :goto_6

    .line 494
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v0}, Landroid/widget/EditText;->getText()Landroid/text/Editable;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 495
    nop

    .line 496
    const/4 v1, 0x0

    const/4 v2, 0x1

    const/4 v3, 0x0

    const/4 v4, 0x1

    :goto_0
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v5

    const/16 v6, 0xa

    if-ge v3, v5, :cond_2

    .line 497
    invoke-virtual {v0, v3}, Ljava/lang/String;->charAt(I)C

    move-result v5

    if-ne v5, v6, :cond_1

    add-int/lit8 v4, v4, 0x1

    .line 496
    :cond_1
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 500
    :cond_2
    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    invoke-virtual {v3}, Landroid/widget/EditText;->getSelectionStart()I

    move-result v3

    .line 501
    nop

    .line 502
    nop

    .line 503
    const/4 v5, 0x0

    const/4 v7, 0x1

    const/4 v8, 0x1

    :goto_1
    if-ge v5, v3, :cond_4

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v9

    if-ge v5, v9, :cond_4

    .line 504
    invoke-virtual {v0, v5}, Ljava/lang/String;->charAt(I)C

    move-result v9

    if-ne v9, v6, :cond_3

    .line 505
    add-int/lit8 v8, v8, 0x1

    .line 506
    const/4 v7, 0x1

    goto :goto_2

    .line 508
    :cond_3
    add-int/lit8 v7, v7, 0x1

    .line 503
    :goto_2
    add-int/lit8 v5, v5, 0x1

    goto :goto_1

    .line 512
    :cond_4
    nop

    .line 513
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    if-eqz v0, :cond_5

    .line 514
    new-instance v0, Ljava/io/File;

    iget-object v3, p0, Lin/startv/hotstar/FileViewerActivity;->filePath:Ljava/lang/String;

    invoke-direct {v0, v3}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 515
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v3

    if-eqz v3, :cond_5

    invoke-virtual {v0}, Ljava/io/File;->length()J

    move-result-wide v5

    goto :goto_3

    .line 519
    :cond_5
    const-wide/16 v5, 0x0

    :goto_3
    const-wide/32 v9, 0x100000

    cmp-long v0, v5, v9

    if-lez v0, :cond_6

    .line 520
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

    .line 521
    :cond_6
    const-wide/16 v9, 0x400

    cmp-long v0, v5, v9

    if-lez v0, :cond_7

    .line 522
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

    .line 524
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

    .line 527
    :goto_4
    iget-boolean v1, p0, Lin/startv/hotstar/FileViewerActivity;->isEdited:Z

    if-eqz v1, :cond_8

    const-string v1, " [Modified]"

    goto :goto_5

    :cond_8
    const-string v1, ""

    .line 528
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

    .line 529
    return-void

    .line 493
    :cond_9
    :goto_6
    return-void
.end method

.method public updateToggleStyle(Landroid/widget/TextView;Z)V
    .locals 2

    .line 603
    new-instance v0, Landroid/graphics/drawable/GradientDrawable;

    invoke-direct {v0}, Landroid/graphics/drawable/GradientDrawable;-><init>()V

    .line 604
    const/4 v1, 0x4

    invoke-virtual {p0, v1}, Lin/startv/hotstar/FileViewerActivity;->dpToPx(I)I

    move-result v1

    int-to-float v1, v1

    invoke-virtual {v0, v1}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V

    .line 605
    if-eqz p2, :cond_0

    .line 606
    const p2, -0xff872c

    invoke-virtual {v0, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    goto :goto_0

    .line 608
    :cond_0
    const/4 p2, 0x0

    invoke-virtual {v0, p2}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    .line 610
    :goto_0
    invoke-virtual {p1, v0}, Landroid/widget/TextView;->setBackground(Landroid/graphics/drawable/Drawable;)V

    .line 611
    return-void
.end method

.method public zoomIn()V
    .locals 2

    .line 371
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x42200000    # 40.0f

    cmpg-float v0, v0, v1

    if-gez v0, :cond_2

    .line 372
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x40000000    # 2.0f

    add-float/2addr v0, v1

    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    .line 373
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setTextSize(F)V

    .line 374
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    .line 375
    :cond_1
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 377
    :cond_2
    return-void
.end method

.method public zoomOut()V
    .locals 2

    .line 381
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x41000000    # 8.0f

    cmpl-float v0, v0, v1

    if-lez v0, :cond_2

    .line 382
    iget v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    const/high16 v1, 0x40000000    # 2.0f

    sub-float/2addr v0, v1

    iput v0, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    .line 383
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->editText:Landroid/widget/EditText;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/EditText;->setTextSize(F)V

    .line 384
    :cond_0
    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lin/startv/hotstar/FileViewerActivity;->lineNumberView:Landroid/widget/TextView;

    iget v1, p0, Lin/startv/hotstar/FileViewerActivity;->currentTextSize:F

    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextSize(F)V

    .line 385
    :cond_1
    invoke-virtual {p0}, Lin/startv/hotstar/FileViewerActivity;->updateLineNumbers()V

    .line 387
    :cond_2
    return-void
.end method
