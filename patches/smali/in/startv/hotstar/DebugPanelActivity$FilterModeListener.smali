.class public Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;
.super Ljava/lang/Object;
.source "DebugPanelActivity.java"

# implements View.OnClickListener
.implements Landroid/view/View$OnClickListener;

# instance fields
.field public outer:Lin/startv/hotstar/DebugPanelActivity;
.field public mode:I    # 0 = Only Block, 1 = Only Allow

.method public constructor <init>(Lin/startv/hotstar/DebugPanelActivity;I)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    iput p2, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->mode:I
    return-void
.end method

.method public onClick(Landroid/view/View;)V
    .locals 5

    iget v0, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->mode:I

    # Persist the mode
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    invoke-static {v1, v0}, Lin/startv/hotstar/HSPatchConfig;->setNetworkFilterMode(Landroid/content/Context;I)V

    # Update button styles
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->outer:Lin/startv/hotstar/DebugPanelActivity;

    # Style "Only Block" button
    iget-object v2, v1, Lin/startv/hotstar/DebugPanelActivity;->btnOnlyBlock:Landroid/widget/TextView;
    if-eqz v2, :skip_block_btn
    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    if-nez v0, :block_inactive
    # mode == 0, block is active
    const v4, -0xbbaa01
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    goto :block_styled
    :block_inactive
    const v4, -0xc8c3bd
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    :block_styled
    const/high16 v4, 0x41000000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    :skip_block_btn

    # Style "Only Allow" button
    iget-object v2, v1, Lin/startv/hotstar/DebugPanelActivity;->btnOnlyAllow:Landroid/widget/TextView;
    if-eqz v2, :skip_allow_btn
    new-instance v3, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v3}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const/4 v4, 0x1
    if-ne v0, v4, :allow_inactive
    # mode == 1, allow is active
    const v4, -0xbb4400
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    goto :allow_styled
    :allow_inactive
    const v4, -0xc8c3bd
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    :allow_styled
    const/high16 v4, 0x41000000
    invoke-virtual {v3, v4}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v2, v3}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    :skip_allow_btn

    # Toast feedback
    iget-object v1, p0, Lin/startv/hotstar/DebugPanelActivity$FilterModeListener;->outer:Lin/startv/hotstar/DebugPanelActivity;
    if-nez v0, :mode_allow

    const-string v2, "\ud83d\udeab Mode: Only Block (blacklist)"
    goto :show_mode_toast

    :mode_allow
    const-string v2, "\u2705 Mode: Only Allow (whitelist)"

    :show_mode_toast
    const/4 v3, 0x1
    invoke-static {v1, v2, v3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    return-void
.end method
