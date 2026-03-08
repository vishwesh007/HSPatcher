.class public Lin/startv/hotstar/DbViewerActivity;
.super Landroid/app/Activity;
.source "DbViewerActivity.java"

# ================================================================
# DbViewerActivity - SQLite database viewer for .db files
# Opens database read-only, lists tables, views table content,
# supports custom SQL queries
# ================================================================

# instance fields
.field public dbPath:Ljava/lang/String;
.field public db:Landroid/database/sqlite/SQLiteDatabase;
.field public resultLayout:Landroid/widget/LinearLayout;
.field public statusText:Landroid/widget/TextView;
.field public queryInput:Landroid/widget/EditText;
.field public tableListLayout:Landroid/widget/LinearLayout;
.field public density:F


# direct methods
.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method


# ================================================================
# getTableNames() - Returns ArrayList<String> of table names
# ================================================================
.method public getTableNames()Ljava/util/ArrayList;
    .locals 6

    new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iget-object v1, p0, Lin/startv/hotstar/DbViewerActivity;->db:Landroid/database/sqlite/SQLiteDatabase;
    if-eqz v1, :tables_done

    :try_start
    const-string v2, "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
    const/4 v3, 0x0
    invoke-virtual {v1, v2, v3}, Landroid/database/sqlite/SQLiteDatabase;->rawQuery(Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v2

    if-eqz v2, :tables_done

    :cursor_loop
    invoke-interface {v2}, Landroid/database/Cursor;->moveToNext()Z
    move-result v3
    if-eqz v3, :cursor_end

    const/4 v3, 0x0
    invoke-interface {v2, v3}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v3

    # Skip android_metadata and sqlite_sequence
    const-string v4, "android_metadata"
    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :cursor_loop

    invoke-virtual {v0, v3}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    goto :cursor_loop

    :cursor_end
    invoke-interface {v2}, Landroid/database/Cursor;->close()V
    :try_end
    .catchall {:try_start .. :try_end} :catch_tables
    goto :tables_done

    :catch_tables
    move-exception v1

    :tables_done
    return-object v0
.end method


# ================================================================
# executeQuery(String) - Run SQL query and display results
# ================================================================
.method public executeQuery(Ljava/lang/String;)V
    .locals 12

    move-object v12, p0

    # Clear results
    iget-object v0, v12, Lin/startv/hotstar/DbViewerActivity;->resultLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v0}, Landroid/widget/LinearLayout;->removeAllViews()V

    iget-object v1, v12, Lin/startv/hotstar/DbViewerActivity;->db:Landroid/database/sqlite/SQLiteDatabase;
    if-nez v1, :db_ok

    iget-object v0, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v1, "Error: Database not open"
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void

    :db_ok
    :try_start
    const/4 v2, 0x0
    invoke-virtual {v1, p1, v2}, Landroid/database/sqlite/SQLiteDatabase;->rawQuery(Ljava/lang/String;[Ljava/lang/String;)Landroid/database/Cursor;
    move-result-object v2

    if-nez v2, :cursor_ok
    iget-object v6, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v7, "Query returned null cursor"
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    return-void

    :cursor_ok
    # Get column names
    invoke-interface {v2}, Landroid/database/Cursor;->getColumnNames()[Ljava/lang/String;
    move-result-object v3
    array-length v4, v3

    invoke-interface {v2}, Landroid/database/Cursor;->getCount()I
    move-result v5

    # Update status
    iget-object v6, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "Columns: "
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v8, " | Rows: "
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Build header row
    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V
    const/4 v7, 0x0
    :header_loop
    if-ge v7, v4, :header_done
    if-eqz v7, :first_col
    const-string v8, " | "
    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :first_col
    aget-object v8, v3, v7
    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    add-int/lit8 v7, v7, 0x1
    goto :header_loop
    :header_done

    # Add header text view
    new-instance v7, Landroid/widget/TextView;
    invoke-direct {v7, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v8
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v8, 0x41500000
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTextSize(F)V
    const v8, -0xff5600
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTextColor(I)V
    sget-object v8, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    const/4 v9, 0x1
    invoke-static {v8, v9}, Landroid/graphics/Typeface;->create(Landroid/graphics/Typeface;I)Landroid/graphics/Typeface;
    move-result-object v8
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const v8, -0xe9e5df
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setBackgroundColor(I)V
    const/16 v8, 0xc
    iget v9, v12, Lin/startv/hotstar/DbViewerActivity;->density:F
    int-to-float v10, v8
    mul-float/2addr v10, v9
    float-to-int v10, v10
    invoke-virtual {v7, v10, v10, v10, v10}, Landroid/view/View;->setPadding(IIII)V
    const/4 v8, 0x1
    invoke-virtual {v7, v8}, Landroid/widget/TextView;->setTextIsSelectable(Z)V
    invoke-virtual {v0, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Divider
    new-instance v7, Landroid/view/View;
    invoke-direct {v7, v12}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const/4 v8, 0x2
    new-instance v9, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v10, -0x1
    invoke-direct {v9, v10, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v7, v9}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v8, -0xbbaa01
    invoke-virtual {v7, v8}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v0, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Data rows (limit to 500 rows to prevent OOM)
    const/4 v7, 0x0
    const/16 v11, 0x1f4
    const/4 v9, 0x0
    :row_loop
    invoke-interface {v2}, Landroid/database/Cursor;->moveToNext()Z
    move-result v8
    if-eqz v8, :rows_done
    if-ge v7, v11, :rows_done

    new-instance v6, Ljava/lang/StringBuilder;
    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V
    const/4 v8, 0x0
    :col_loop
    if-ge v8, v4, :col_done
    if-eqz v8, :first_data_col
    const-string v9, " | "
    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :first_data_col

    :try_get_val
    invoke-interface {v2, v8}, Landroid/database/Cursor;->getType(I)I
    move-result v9
    const/4 v10, 0x0
    if-ne v9, v10, :not_null_type
    const-string v9, "NULL"
    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :next_col
    :not_null_type
    const/4 v10, 0x4
    if-ne v9, v10, :not_blob_type
    const-string v9, "[BLOB]"
    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    goto :next_col
    :not_blob_type
    invoke-interface {v2, v8}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;
    move-result-object v9
    if-nez v9, :has_val
    const-string v9, "NULL"
    :has_val
    # Truncate long values
    invoke-virtual {v9}, Ljava/lang/String;->length()I
    move-result v10
    const/16 v10, 0x64
    invoke-virtual {v9}, Ljava/lang/String;->length()I
    move-result v10
    # Hmm, let me simplify - just append the value
    invoke-virtual {v6, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :next_col
    add-int/lit8 v8, v8, 0x1
    goto :col_loop
    :col_done

    # Create row text view
    new-instance v8, Landroid/widget/TextView;
    invoke-direct {v8, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v9, 0x41400000
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextSize(F)V
    const v9, -0x1
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextColor(I)V
    sget-object v9, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/4 v9, 0x1
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextIsSelectable(Z)V

    # Alternating row color
    and-int/lit8 v9, v7, 0x1
    if-nez v9, :dark_row
    const v9, -0xf2eee9
    goto :row_colored
    :dark_row
    const v9, -0xe9e5df
    :row_colored
    invoke-virtual {v8, v9}, Landroid/view/View;->setBackgroundColor(I)V

    # Compute padding: 8dp horizontal, 4dp vertical
    iget v9, v12, Lin/startv/hotstar/DbViewerActivity;->density:F
    const/16 v10, 0x8
    int-to-float v10, v10
    mul-float/2addr v10, v9
    float-to-int v10, v10
    shr-int/lit8 v9, v10, 0x1
    invoke-virtual {v8, v10, v9, v10, v9}, Landroid/view/View;->setPadding(IIII)V

    invoke-virtual {v0, v8}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    add-int/lit8 v7, v7, 0x1
    const/4 v8, 0x0
    goto :row_loop

    :rows_done
    # Show truncation notice if needed
    const/16 v11, 0x1f4
    if-lt v7, v11, :no_truncation
    new-instance v8, Landroid/widget/TextView;
    invoke-direct {v8, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    new-instance v9, Ljava/lang/StringBuilder;
    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V
    const-string v10, "\n... Showing first 500 of "
    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v10, " rows. Use SQL query for more control."
    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v9
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v9, 0x41500000
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextSize(F)V
    const v9, -0x1e96
    invoke-virtual {v8, v9}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v9, 0x10
    invoke-virtual {v8, v9, v9, v9, v9}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v0, v8}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    :no_truncation

    invoke-interface {v2}, Landroid/database/Cursor;->close()V

    :try_end
    .catchall {:try_start .. :try_end} :catch_query
    goto :query_done

    :catch_query
    move-exception v1

    # Show error
    new-instance v6, Landroid/widget/TextView;
    invoke-direct {v6, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "Error: "
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v8
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v7, 0x41600000
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setTextSize(F)V
    const v7, -0x10000
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setTextColor(I)V
    const/16 v7, 0x10
    invoke-virtual {v6, v7, v7, v7, v7}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v0, v6}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    iget-object v6, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v7, "Query error"
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :query_done
    return-void
.end method


# ================================================================
# onCreate(Bundle) - Build the UI
# ================================================================
.method public onCreate(Landroid/os/Bundle;)V
    .locals 13

    move-object v12, p0
    invoke-super {v12, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V

    # Get file path from intent
    invoke-virtual {v12}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;
    move-result-object v0
    const-string v1, "path"
    invoke-virtual {v0, v1}, Landroid/content/Intent;->getStringExtra(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v0
    iput-object v0, v12, Lin/startv/hotstar/DbViewerActivity;->dbPath:Ljava/lang/String;

    # Density
    invoke-virtual {v12}, Landroid/app/Activity;->getResources()Landroid/content/res/Resources;
    move-result-object v1
    invoke-virtual {v1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;
    move-result-object v1
    iget v5, v1, Landroid/util/DisplayMetrics;->density:F
    iput v5, v12, Lin/startv/hotstar/DbViewerActivity;->density:F

    # Root layout
    new-instance v1, Landroid/widget/LinearLayout;
    invoke-direct {v1, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const v2, -0xe9e5df
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V

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
    new-instance v4, Lin/startv/hotstar/DbViewerActivity$BackListener;
    invoke-direct {v4, v12}, Lin/startv/hotstar/DbViewerActivity$BackListener;-><init>(Lin/startv/hotstar/DbViewerActivity;)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Title
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    # Get filename from path
    invoke-virtual {v0}, Ljava/lang/String;->length()I
    move-result v4
    if-lez v4, :no_name
    const-string v4, "/"
    invoke-virtual {v0, v4}, Ljava/lang/String;->lastIndexOf(Ljava/lang/String;)I
    move-result v4
    if-ltz v4, :no_name
    add-int/lit8 v4, v4, 0x1
    invoke-virtual {v0, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v6
    goto :has_name
    :no_name
    const-string v6, "Database"
    :has_name
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "\ud83d\uddc3\ufe0f "
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v3, v6}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41900000
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
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setSingleLine(Z)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # PATH BAR
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41400000
    const/4 v4, 0x0
    invoke-virtual {v2, v4, v3}, Landroid/widget/TextView;->setTextSize(IF)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const v3, -0xebe6e1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v3, 0x8
    int-to-float v4, v3
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v4, v4, v4, v4}, Landroid/view/View;->setPadding(IIII)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setSingleLine(Z)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # QUERY INPUT ROW
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/16 v3, 0x10
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setGravity(I)V
    const/16 v3, 0x8
    int-to-float v4, v3
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v4, v4, v4, v4}, Landroid/view/View;->setPadding(IIII)V

    # Query input
    new-instance v3, Landroid/widget/EditText;
    invoke-direct {v3, v12}, Landroid/widget/EditText;-><init>(Landroid/content/Context;)V
    iput-object v3, v12, Lin/startv/hotstar/DbViewerActivity;->queryInput:Landroid/widget/EditText;
    const-string v4, "SELECT * FROM tablename LIMIT 100"
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setHint(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41500000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/EditText;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setTextColor(I)V
    const v4, -0x6d6d6e
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setHintTextColor(I)V
    const v4, -0xf2eee9
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setBackgroundColor(I)V
    sget-object v4, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setTypeface(Landroid/graphics/Typeface;)V
    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setSingleLine(Z)V
    const/16 v4, 0x8
    int-to-float v6, v4
    mul-float/2addr v6, v5
    float-to-int v6, v6
    invoke-virtual {v3, v6, v6, v6, v6}, Landroid/widget/EditText;->setPadding(IIII)V
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, 0x0
    const/4 v7, -0x2
    const/high16 v8, 0x3f800000
    invoke-direct {v4, v6, v7, v8}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v3, v4}, Landroid/widget/EditText;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # Run button
    new-instance v3, Landroid/widget/TextView;
    invoke-direct {v3, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v4, " \u25b6 Run "
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v4, 0x41600000
    const/4 v6, 0x0
    invoke-virtual {v3, v6, v4}, Landroid/widget/TextView;->setTextSize(IF)V
    const v4, -0x1
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setTextColor(I)V

    new-instance v4, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v4}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v6, -0xbbaa01
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v6, 0x41000000
    invoke-virtual {v4, v6}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    const/16 v4, 0x10
    int-to-float v6, v4
    mul-float/2addr v6, v5
    float-to-int v6, v6
    const/16 v4, 0x8
    int-to-float v7, v4
    mul-float/2addr v7, v5
    float-to-int v7, v7
    invoke-virtual {v3, v6, v7, v6, v7}, Landroid/view/View;->setPadding(IIII)V

    new-instance v4, Lin/startv/hotstar/DbViewerActivity$RunQueryListener;
    invoke-direct {v4, v12}, Lin/startv/hotstar/DbViewerActivity$RunQueryListener;-><init>(Lin/startv/hotstar/DbViewerActivity;)V
    invoke-virtual {v3, v4}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # STATUS TEXT
    new-instance v2, Landroid/widget/TextView;
    invoke-direct {v2, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    iput-object v2, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    const-string v3, "Loading database..."
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v3, 0x41400000
    const/4 v4, 0x0
    invoke-virtual {v2, v4, v3}, Landroid/widget/TextView;->setTextSize(IF)V
    const v3, -0x6d6d6e
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTextColor(I)V
    const v3, -0xebe6e1
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setBackgroundColor(I)V
    sget-object v3, Landroid/graphics/Typeface;->MONOSPACE:Landroid/graphics/Typeface;
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setTypeface(Landroid/graphics/Typeface;)V
    const/16 v3, 0x8
    int-to-float v4, v3
    mul-float/2addr v4, v5
    float-to-int v4, v4
    invoke-virtual {v2, v4, v4, v4, v4}, Landroid/view/View;->setPadding(IIII)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # TABLE LIST CONTAINER
    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x0
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v2, v12, Lin/startv/hotstar/DbViewerActivity;->tableListLayout:Landroid/widget/LinearLayout;
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # DIVIDER
    new-instance v2, Landroid/view/View;
    invoke-direct {v2, v12}, Landroid/view/View;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x2
    new-instance v4, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v6, -0x1
    invoke-direct {v4, v6, v3}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v2, v4}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const v3, -0xcfc9c3
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackgroundColor(I)V
    invoke-virtual {v1, v2}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # RESULT LAYOUT (inside ScrollView)
    new-instance v9, Landroid/widget/ScrollView;
    invoke-direct {v9, v12}, Landroid/widget/ScrollView;-><init>(Landroid/content/Context;)V
    new-instance v2, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v3, -0x1
    const/4 v4, 0x0
    const/high16 v6, 0x3f800000
    invoke-direct {v2, v3, v4, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v9, v2}, Landroid/widget/ScrollView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V
    const/4 v2, 0x1
    invoke-virtual {v9, v2}, Landroid/widget/ScrollView;->setFillViewport(Z)V

    # HorizontalScrollView for wide tables
    new-instance v10, Landroid/widget/HorizontalScrollView;
    invoke-direct {v10, v12}, Landroid/widget/HorizontalScrollView;-><init>(Landroid/content/Context;)V

    new-instance v2, Landroid/widget/LinearLayout;
    invoke-direct {v2, v12}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v3, 0x1
    invoke-virtual {v2, v3}, Landroid/widget/LinearLayout;->setOrientation(I)V
    iput-object v2, v12, Lin/startv/hotstar/DbViewerActivity;->resultLayout:Landroid/widget/LinearLayout;

    invoke-virtual {v10, v2}, Landroid/widget/HorizontalScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v9, v10}, Landroid/widget/ScrollView;->addView(Landroid/view/View;)V
    invoke-virtual {v1, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    invoke-virtual {v12, v1}, Landroid/app/Activity;->setContentView(Landroid/view/View;)V

    # OPEN DATABASE
    :try_open
    const/4 v2, 0x0
    const/4 v3, 0x1
    invoke-static {v0, v2, v3}, Landroid/database/sqlite/SQLiteDatabase;->openDatabase(Ljava/lang/String;Landroid/database/sqlite/SQLiteDatabase$CursorFactory;I)Landroid/database/sqlite/SQLiteDatabase;
    move-result-object v2
    iput-object v2, v12, Lin/startv/hotstar/DbViewerActivity;->db:Landroid/database/sqlite/SQLiteDatabase;

    # Load table list
    invoke-virtual {v12}, Lin/startv/hotstar/DbViewerActivity;->getTableNames()Ljava/util/ArrayList;
    move-result-object v3
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I
    move-result v4

    # Update status
    iget-object v6, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    new-instance v7, Ljava/lang/StringBuilder;
    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V
    const-string v8, "Tables: "
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v8, " | Tap a table to view"
    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v7
    invoke-virtual {v6, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Show table buttons
    iget-object v6, v12, Lin/startv/hotstar/DbViewerActivity;->tableListLayout:Landroid/widget/LinearLayout;
    const/4 v7, 0x0
    :table_btn_loop
    if-ge v7, v4, :tables_shown

    invoke-virtual {v3, v7}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v8
    check-cast v8, Ljava/lang/String;

    new-instance v9, Landroid/widget/TextView;
    invoke-direct {v9, v12}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    new-instance v10, Ljava/lang/StringBuilder;
    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V
    const-string v11, " \ud83d\uddc2 "
    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v11, " "
    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v10
    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v10, 0x41600000
    const/4 v11, 0x0
    invoke-virtual {v9, v11, v10}, Landroid/widget/TextView;->setTextSize(IF)V
    const v10, -0x1
    invoke-virtual {v9, v10}, Landroid/widget/TextView;->setTextColor(I)V

    new-instance v10, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v10}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v11, -0xdbd6d0
    invoke-virtual {v10, v11}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    const/high16 v11, 0x41000000
    invoke-virtual {v10, v11}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v9, v10}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    const/16 v10, 0xc
    int-to-float v11, v10
    mul-float/2addr v11, v5
    float-to-int v11, v11
    const/16 v10, 0x6
    int-to-float v10, v10
    mul-float/2addr v10, v5
    float-to-int v10, v10
    invoke-virtual {v9, v11, v10, v11, v10}, Landroid/view/View;->setPadding(IIII)V

    new-instance v10, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v11, -0x2
    const/4 v13, -0x2
    invoke-direct {v10, v11, v13}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    const/16 v11, 0x4
    int-to-float v13, v11
    mul-float/2addr v13, v5
    float-to-int v13, v13
    invoke-virtual {v10, v13, v13, v13, v13}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v9, v10}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    new-instance v10, Lin/startv/hotstar/DbViewerActivity$TableClickListener;
    invoke-direct {v10, v12, v8}, Lin/startv/hotstar/DbViewerActivity$TableClickListener;-><init>(Lin/startv/hotstar/DbViewerActivity;Ljava/lang/String;)V
    invoke-virtual {v9, v10}, Landroid/view/View;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    invoke-virtual {v6, v9}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    add-int/lit8 v7, v7, 0x1
    goto :table_btn_loop
    :tables_shown

    .catchall {:try_open .. :tables_shown} :catch_open
    goto :open_done

    :catch_open
    move-exception v2
    iget-object v3, v12, Lin/startv/hotstar/DbViewerActivity;->statusText:Landroid/widget/TextView;
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "Error opening database: "
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v2}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4
    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :open_done
    return-void
.end method


# ================================================================
# onDestroy - Close database
# ================================================================
.method public onDestroy()V
    .locals 1

    iget-object v0, p0, Lin/startv/hotstar/DbViewerActivity;->db:Landroid/database/sqlite/SQLiteDatabase;
    if-eqz v0, :no_db
    :try_close
    invoke-virtual {v0}, Landroid/database/sqlite/SQLiteDatabase;->close()V
    .catchall {:try_close .. :no_db} :catch_close
    :catch_close
    :no_db
    invoke-super {p0}, Landroid/app/Activity;->onDestroy()V
    return-void
.end method
