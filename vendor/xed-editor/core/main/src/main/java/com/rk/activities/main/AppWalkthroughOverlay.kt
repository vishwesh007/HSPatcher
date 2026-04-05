package com.rk.activities.main

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Build
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.List
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.rk.resources.getString
import com.rk.resources.strings
import com.rk.settings.Settings

object AppWalkthroughController {
    var isVisible by mutableStateOf(false)
        private set

    fun show() {
        isVisible = true
    }

    fun dismiss(markShown: Boolean) {
        if (markShown) {
            Settings.shown_walkthrough = true
        }
        isVisible = false
    }
}

private data class WalkthroughStep(
    val icon: ImageVector,
    val title: Int,
    val body: Int,
    val accent: Color,
)

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun AppWalkthroughOverlay(
    visible: Boolean,
    onDismiss: () -> Unit,
) {
    if (!visible) return

    val steps =
        remember {
            listOf(
                WalkthroughStep(Icons.Outlined.Menu, strings.walkthrough_step_one_title, strings.walkthrough_step_one_body, Color(0xFF2F7CFF)),
                WalkthroughStep(Icons.Outlined.Edit, strings.walkthrough_step_two_title, strings.walkthrough_step_two_body, Color(0xFF109A5B)),
                WalkthroughStep(Icons.Outlined.List, strings.walkthrough_step_three_title, strings.walkthrough_step_three_body, Color(0xFFE09714)),
                WalkthroughStep(Icons.Outlined.PlayArrow, strings.walkthrough_step_four_title, strings.walkthrough_step_four_body, Color(0xFFD94A54)),
                WalkthroughStep(Icons.Outlined.Build, strings.walkthrough_step_five_title, strings.walkthrough_step_five_body, Color(0xFF7A52FF)),
            )
        }
    var currentStep by remember { mutableIntStateOf(0) }
    val current = steps[currentStep]
    val isLastStep = currentStep == steps.lastIndex
    val infiniteTransition = rememberInfiniteTransition(label = "walkthrough")
    val pulse by
        infiniteTransition.animateFloat(
            initialValue = 0.96f,
            targetValue = 1.04f,
            animationSpec = infiniteRepeatable(animation = tween(1600, easing = FastOutSlowInEasing), repeatMode = RepeatMode.Reverse),
            label = "walkthroughPulse",
        )
    val glowAlpha by
        infiniteTransition.animateFloat(
            initialValue = 0.12f,
            targetValue = 0.24f,
            animationSpec = infiniteRepeatable(animation = tween(1400, easing = FastOutSlowInEasing), repeatMode = RepeatMode.Reverse),
            label = "walkthroughGlow",
        )

    BackHandler { onDismiss() }

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.surface.copy(alpha = 0.985f),
    ) {
        Box(
            modifier =
                Modifier
                    .fillMaxSize()
                    .background(
                        Brush.verticalGradient(
                            listOf(
                                MaterialTheme.colorScheme.surface,
                                MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.55f),
                                MaterialTheme.colorScheme.surface,
                            )
                        )
                    )
                    .padding(20.dp)
        ) {
            Box(
                modifier =
                    Modifier
                        .align(Alignment.TopEnd)
                        .padding(top = 24.dp)
                        .size(120.dp)
                        .scale(pulse)
                        .alpha(glowAlpha)
                        .clip(CircleShape)
                        .background(current.accent)
            )

            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.SpaceBetween,
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Text(
                        text = strings.walkthrough_header.getString(),
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = strings.walkthrough_subtitle.getString(),
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }

                AnimatedContent(
                    targetState = currentStep,
                    transitionSpec = {
                        (slideInHorizontally { width -> width / 5 } + fadeIn()) togetherWith
                            (slideOutHorizontally { width -> -width / 6 } + fadeOut())
                    },
                    label = "walkthroughContent",
                ) { index ->
                    val step = steps[index]
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(28.dp),
                        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceContainerHigh),
                    ) {
                        Column(
                            modifier = Modifier.padding(horizontal = 20.dp, vertical = 24.dp),
                            verticalArrangement = Arrangement.spacedBy(18.dp),
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(
                                    modifier = Modifier.size(56.dp).clip(CircleShape).background(step.accent.copy(alpha = 0.16f)),
                                    contentAlignment = Alignment.Center,
                                ) {
                                    Icon(step.icon, contentDescription = null, tint = step.accent, modifier = Modifier.size(30.dp))
                                }
                                Spacer(modifier = Modifier.width(14.dp))
                                Text(
                                    text = "${index + 1}/${steps.size}",
                                    style = MaterialTheme.typography.labelLarge,
                                    color = step.accent,
                                )
                            }

                            Text(
                                text = step.title.getString(),
                                style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.SemiBold,
                            )

                            Text(
                                text = step.body.getString(),
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }

                Column(verticalArrangement = Arrangement.spacedBy(18.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Center,
                    ) {
                        steps.forEachIndexed { index, step ->
                            Box(
                                modifier =
                                    Modifier
                                        .padding(horizontal = 4.dp)
                                        .height(10.dp)
                                        .width(if (index == currentStep) 28.dp else 10.dp)
                                        .clip(CircleShape)
                                        .background(if (index == currentStep) step.accent else MaterialTheme.colorScheme.outline.copy(alpha = 0.35f))
                            )
                        }
                    }

                    Text(
                        text = strings.walkthrough_hint.getString(),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth(),
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                    ) {
                        OutlinedButton(onClick = onDismiss, modifier = Modifier.weight(1f)) {
                            Text(strings.walkthrough_skip.getString())
                        }
                        Button(
                            onClick = {
                                if (isLastStep) {
                                    onDismiss()
                                } else {
                                    currentStep += 1
                                }
                            },
                            modifier = Modifier.weight(1f),
                        ) {
                            Text(if (isLastStep) strings.walkthrough_finish.getString() else strings.walkthrough_next.getString())
                        }
                    }
                }
            }
        }
    }
}