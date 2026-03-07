.class public Lin/startv/hotstar/HostFilterActivity;
.super Landroid/app/Activity;
.source "HostFilterActivity.java"

# ================================================================
# HostFilterActivity - Manage discovered hosts (ALLOW/DENY)
# Shows all hosts from host_rules.txt with toggle switches
# ================================================================

# instance fields
.field public hostListLayout:Landroid/widget/LinearLayout;
.field public statusText:Landroid/widget/TextView;
.field public hostCount:I
.field public denyCount:I

# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method


# ================================================================
# loadHosts() - Read host_rules.txt, return as ArrayList of String[]
# Each entry: [hostname, status]
# ================================================================
.method public loadHosts()Ljava/util/ArrayList;
    .locals 7

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    :try_start
    invoke-static {}, Lin/startv/hotstar/HSPatchConfig;->getHostRulesFilePath()Ljava/lang/String;
    move-result-object v1
    if-eqz v1, :load_done

    new-instance v2, Ljava/io/File;
    invoke-direct {v2, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v2}, Ljava/io/File;->exists()Z
    move-result v3
    if-eqz v3, :load_done

    new-instance v2, Ljava/io/BufferedReader;
    new-instance v3, Ljava/io/FileReader;
    invoke-direct {v3, v1}, Ljava/io/FileReader;-><init>(Ljava/lang/String;)V
    invoke-direct {v2, v3}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    :read_loop
    invoke-virtual {v2}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;
    move-result-object v3
    if-eqz v3, :read_done

    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/String;->length()I
    move-result v4
    if-lez v4, :read_loop

    const/16 v4, 0x23    # '#'
    invoke-virtual {v3, v4}, Ljava/lang/String;->indexOf(I)I
    move-result v4
    if-eqz v4, :read_loop    # skip comments

    const-string v4, " "
    invoke-virtual {v3, v4}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I
    move-result v5
    if-lez v5, :read_loop

    const/4 v6, 0x2
    new-array v4, v6, [Ljava/lang/String;

    const/4 v6, 0x0
    invoke-virtual {v3, v6, v5}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v6}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v6
    const/4 v4, 0x0
    # We need temp to store the array and the values
    # Let's use a simpler approach
    goto :read_loop_parse

    :read_loop_parse
    # Re-parse: split by space
    const-string v4, " "
    const/4 v5, 0x2
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;
    move-result-object v4
    array-length v5, v4
    const/4 v6, 0x2
    if-lt v5, v6, :read_loop

    invoke-virtual {v0, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    goto :read_loop

    :read_done
    invoke-virtual {v2}, Ljava/io/BufferedReader;->close()V

    :try_end
    .catchall {:try_start .. :try_end} :catch_load
    goto :load_done

    :catch_load
    move-exception v1

    :load_done
    return-object v0
.end method


# ================================================================
# saveHosts(ArrayList) - Write host_rules.txt
# ================================================================
.method public saveHosts(Ljava/util/ArrayList;)V
    .locals 6

    :try_start
    invoke-static {}, Lin/startv/hotstar/HSPatchConfig;->getHostRulesFilePath()Ljava/lang/String;
    move-result-object v0
    if-eqz v0, :save_done

    new-instance v1, Ljava/io/FileWriter;
    const/4 v2, 0x0
    invoke-direct {v1, v0, v2}, Ljava/io/FileWriter;-><init>(Ljava/lang/String;Z)V

    const-string v2, "# Host rules - format: hostname ALLOW/DENY\n# Managed by HSPatch Host Filter\n"
    invoke-virtual {v1, v2}, Ljava/io/Writer;->write(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/util/ArrayList;->size()I
    move-result v2
    const/4 v3, 0x0

    :save_loop
    if-ge v3, v2, :save_flush
    invoke-virtual {p1, v3}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v4
    check-cast v4, [Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;
    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V
    const/4 v0, 0x0
    aget-object v0, v4, v0
    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, " "
    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const/4 v0, 0x1
    aget-object v0, v4, v0
    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v0, "\n"
    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Ljava/io/Writer;->write(Ljava/lang/String;)V

    add-int/lit8 v3, v3, 0x1
    goto :save_loop

    :save_flush
    invoke-virtual {v1}, Ljava/io/Writer;->flush()V
    invoke-virtual {v1}, Ljava/io/Writer;->close()V

    :try_end
    .catchall {:try_start .. :try_end} :catch_save
    goto :save_done

    :catch_save
    move-exception v0

    :save_done
    return-void
.end method


# ================================================================
# updateStatus() - Update status bar text
# ================================================================
.method public updateStatus()V
    .locals 4

    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity;->statusText:Landroid/widget/TextView;
    if-eqz v0, :status_done

    new-instance v1, Ljava/lang/StringBuilder;
    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "Hosts: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lin/startv/hotstar/HostFilterActivity;->hostCount:I
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " | Denied: "
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lin/startv/hotstar/HostFilterActivity;->denyCount:I
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    sget v2, Lin/startv/hotstar/HSPatchConfig;->networkFilterMode:I
    if-nez v2, :mode_allow_status
    const-string v2, " | Mode: Only Block"
    goto :mode_done_status
    :mode_allow_status
    const-string v2, " | Mode: Only Allow"
    :mode_done_status
    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v1
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :status_done
    return-void
.end method


# ================================================================
# onCreate(Bundle) - Build the UI
# ================================================================
.method public onCreate(Landroid/os/Bundle;)V
    .locals 16

    move-object/from16 v12, p0
    invoke-super/range {p0 .. p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # Density
    invoke-virtual/range {p0 .. p0}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v0
    invoke-virtual {v0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v0
    iget v5, v0, Landroid/util/DisplayMetrics;->density:F

    # Root ScrollView
    new-instance v0, Landroid/widget/ScrollView;
    invoke-direct {v0, v12}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    const v1, -0xe9e5df
    invoke-virtual {v0, v1}, Landroid/view/View;->setBackgroundColor(I)V

    # Main vertical layout
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    # TOOLBAR
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v3, -0xebe6e1
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setBackgroundColor(I)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v3, 0xc
    int-to-float v4, v3
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v4, v4, v4, v4}, Landroid/view/View;->setPadding(IIII)V

    # Back button
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \u2190 "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41e00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v4, Lin/startv/hotstar/HostFilterActivity$BackListener;
    invoke-direct {v4, v12}, Lin/startv/hotstar/HostFilterActivity$BackListener;-><init>(Lin/startv/hotstar/HostFilterActivity;)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Title
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, "\ud83d\udee1\ufe0f Host Filter Manager"
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41a00000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, 0x0
    const/4 v7, -0x2
    const/high16 v8, 0x3f800000
    invoke-direct {v4, v6, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # STATUS TEXT
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, v12, Lin/startv/hotstar/HostFilterActivity;->statusText:Landroid/widget/TextView;
    const-string v3, "Loading..."
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41500000
    const/4 v4, 0x0
    invoke-virtual {v2, v4, v3}, Landroid/widget/TextView;->setTextSize(IF)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const v3, -0xebe6e1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v3, 0xc
    int-to-float v4, v3
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v4, v4, v4, v4}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # HOST LIST CONTAINER (inside a ScrollView)
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v2, v12, Lin/startv/hotstar/HostFilterActivity;->hostListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Set content
    invoke-virtual {v0, v1}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v12, v0}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    # LOAD AND DISPLAY HOSTS
    invoke-virtual {v12}, Lin/startv/hotstar/HostFilterActivity;->loadHosts()Ljava/util/ArrayList;
    move-result-object v6

    invoke-virtual {v6}, Ljava/util/ArrayList;->size()I
    move-result v7
    iput v7, v12, Lin/startv/hotstar/HostFilterActivity;->hostCount:I
    const/4 v8, 0x0
    iput v8, v12, Lin/startv/hotstar/HostFilterActivity;->denyCount:I

    const/4 v8, 0x0
    :host_loop
    if-ge v8, v7, :hosts_loaded

    invoke-virtual {v6, v8}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v9
    check-cast v9, [Ljava/lang/String;

    const/4 v10, 0x0
    aget-object v10, v9, v10
    const/4 v11, 0x1
    aget-object v11, v9, v11

    # Check if DENY to count
    const-string v13, "DENY"
    invoke-virtual {v11, v13}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v13
    if-eqz v13, :not_deny
    iget v13, v12, Lin/startv/hotstar/HostFilterActivity;->denyCount:I
    add-int/lit8 v13, v13, 0x1
    iput v13, v12, Lin/startv/hotstar/HostFilterActivity;->denyCount:I
    :not_deny

    # Create host row: horizontal layout with hostname + switch
    new-instance v13, Landroid/widget/LinearLayout;
    invoke-direct {v13, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v14, 0x0
    invoke-virtual {v13, v14}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v14, 0x10
    invoke-virtual {v13, v14}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v14, 0x8
    const/16 v15, 0x4
    invoke-virtual {v13, v14, v15, v14, v15}, Landroid/view/View;->setPadding(IIII)V

    # Alternating row color
    and-int/lit8 v14, v8, 0x1
    if-nez v14, :row_dark
    const v14, -0xf2eee9
    goto :row_colored
    :row_dark
    const v14, -0xe9e5df
    :row_colored
    invoke-virtual {v13, v14}, Landroid/view/View;->setBackgroundColor(I)V

    # Hostname text
    new-instance v14, Landroid/widget/TextView;
    invoke-direct {v14, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v14, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v15, 0x41400000
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTextSize(F)V
    const/4 v15, -0x1
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTextColor(I)V
    sget-object v15, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    new-instance v15, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, 0x0
    const/4 v4, -0x2
    const/high16 v2, 0x3f800000
    invoke-direct {v15, v3, v4, v2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v14, v15}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v13, v14}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Status label (ALLOW/DENY)
    new-instance v14, Landroid/widget/TextView;
    invoke-direct {v14, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const/high16 v15, 0x41400000
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTextSize(F)V
    const/16 v15, 0x11
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setGravity(I)V

    const-string v15, "DENY"
    invoke-virtual {v11, v15}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v15
    if-eqz v15, :label_allow
    const-string v15, " DENY "
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v15, -0x10000
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTextColor(I)V
    goto :label_done
    :label_allow
    const-string v15, " ALLOW "
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v15, -0xff5600
    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setTextColor(I)V
    :label_done
    const/16 v15, 0xc
    int-to-float v2, v15
    mul-float/2addr v2, v5
    float-to-int v2, v2
    const/4 v3, 0x0
    invoke-virtual {v14, v2, v3, v2, v3}, Landroid/view/View;->setPadding(IIII)V

    # Switch
    new-instance v15, Landroid/widget/Switch;
    invoke-direct {v15, v12}, Landroid/widget/Switch;-><init>(Landroid/content/Context;)V

    const-string v2, "DENY"
    invoke-virtual {v11, v2}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    move-result v2
    if-eqz v2, :switch_on
    const/4 v2, 0x0
    invoke-virtual {v15, v2}, Landroid/widget/CompoundButton;->setChecked(Z)V
    goto :switch_set
    :switch_on
    const/4 v2, 0x1
    invoke-virtual {v15, v2}, Landroid/widget/CompoundButton;->setChecked(Z)V
    :switch_set

    # Listener
    new-instance v2, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;
    invoke-direct {v2, v12, v6, v8, v14}, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;-><init>(Lin/startv/hotstar/HostFilterActivity;Ljava/util/ArrayList;ILandroid/widget/TextView;)V
    invoke-virtual {v15, v2}, Landroid/widget/CompoundButton;->setOnCheckedChangeListener(Landroid/widget/CompoundButton$OnCheckedChangeListener;)V

    invoke-virtual {v13, v14}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v13, v15}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    iget-object v2, v12, Lin/startv/hotstar/HostFilterActivity;->hostListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v2, v13}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    add-int/lit8 v8, v8, 0x1
    goto :host_loop

    :hosts_loaded
    if-nez v7, :has_hosts
    # Show empty message
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v3, "\n  No hosts discovered yet.\n  Open the app and browse to discover network hosts.\n  They will appear here automatically.\n"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41700000
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextSize(F)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v3, 0x20
    invoke-virtual {v2, v3, v3, v3, v3}, Landroid/view/View;->setPadding(IIII)V
    iget-object v3, v12, Lin/startv/hotstar/HostFilterActivity;->hostListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v3, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    :has_hosts

    invoke-virtual {v12}, Lin/startv/hotstar/HostFilterActivity;->updateStatus()V

    return-void
.end method
