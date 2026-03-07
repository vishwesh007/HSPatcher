.class public Lin/startv/hotstar/HostFilterActivity$HostToggleListener;
.super Ljava/lang/Object;
.source "HostFilterActivity.java"

.implements Landroid/widget/CompoundButton$OnCheckedChangeListener;

# instance fields
.field public outer:Lin/startv/hotstar/HostFilterActivity;
.field public hostList:Ljava/util/ArrayList;
.field public index:I
.field public statusLabel:Landroid/widget/TextView;

.method public constructor <init>(Lin/startv/hotstar/HostFilterActivity;Ljava/util/ArrayList;ILandroid/widget/TextView;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->outer:Lin/startv/hotstar/HostFilterActivity;
    iput-object p2, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->hostList:Ljava/util/ArrayList;
    iput p3, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->index:I
    iput-object p4, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->statusLabel:Landroid/widget/TextView;
    return-void
.end method

.method public onCheckedChanged(Landroid/widget/CompoundButton;Z)V
    .locals 4

    # Get the host entry array
    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->hostList:Ljava/util/ArrayList;
    iget v1, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->index:I
    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;
    move-result-object v0
    check-cast v0, [Ljava/lang/String;

    # checked=true -> ALLOW, checked=false -> DENY
    if-eqz p2, :set_deny
    const-string v1, "ALLOW"
    goto :update_entry
    :set_deny
    const-string v1, "DENY"
    :update_entry
    const/4 v2, 0x1
    aput-object v1, v0, v2

    # Update the status label text and color
    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->statusLabel:Landroid/widget/TextView;
    if-eqz v0, :skip_label

    if-eqz p2, :label_deny
    const-string v1, " ALLOW "
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v1, -0xff5600
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V
    goto :skip_label

    :label_deny
    const-string v1, " DENY "
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const v1, -0x10000
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setTextColor(I)V

    :skip_label

    # Update deny count (simple increment/decrement)
    iget-object v0, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->outer:Lin/startv/hotstar/HostFilterActivity;
    iget v1, v0, Lin/startv/hotstar/HostFilterActivity;->denyCount:I
    if-eqz p2, :inc_deny
    # toggled to ALLOW -> was DENY -> decrement
    if-lez v1, :deny_floor
    add-int/lit8 v1, v1, -0x1
    :deny_floor
    goto :deny_updated
    :inc_deny
    # toggled to DENY -> was ALLOW -> increment
    add-int/lit8 v1, v1, 0x1
    :deny_updated
    iput v1, v0, Lin/startv/hotstar/HostFilterActivity;->denyCount:I

    # Update status bar
    invoke-virtual {v0}, Lin/startv/hotstar/HostFilterActivity;->updateStatus()V

    # Save to file
    iget-object v1, p0, Lin/startv/hotstar/HostFilterActivity$HostToggleListener;->hostList:Ljava/util/ArrayList;
    invoke-virtual {v0, v1}, Lin/startv/hotstar/HostFilterActivity;->saveHosts(Ljava/util/ArrayList;)V

    return-void
.end method
