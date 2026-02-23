.class public Lin/startv/hotstar/FileExplorerActivity$FileComparator;
.super Ljava/lang/Object;
.source "FileExplorerActivity.java"

.implements Ljava/util/Comparator;

.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lin/startv/hotstar/FileExplorerActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FileComparator"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Ljava/util/Comparator<",
        "Ljava/io/File;",
        ">;"
    }
.end annotation

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# compare(File, File) - directories first, then alphabetical (case insensitive)
.method public compare(Ljava/lang/Object;Ljava/lang/Object;)I
    .locals 4
    check-cast p1, Ljava/io/File;
    check-cast p2, Ljava/io/File;

    # Check if both are directories or both are files
    invoke-virtual {p1}, Ljava/io/File;->isDirectory()Z
    move-result v0

    invoke-virtual {p2}, Ljava/io/File;->isDirectory()Z
    move-result v1

    # If a is dir and b is not, a comes first (-1)
    if-eqz v0, :a_not_dir
    if-nez v1, :both_same_type
    const/4 v0, -0x1
    return v0

    :a_not_dir
    # If a is not dir and b is dir, b comes first (1)
    if-eqz v1, :both_same_type
    const/4 v0, 0x1
    return v0

    :both_same_type
    # Both same type - compare names case insensitive
    invoke-virtual {p1}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v2

    invoke-virtual {p2}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/String;->compareTo(Ljava/lang/String;)I
    move-result v0
    return v0
.end method
