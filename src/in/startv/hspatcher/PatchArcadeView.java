package in.startv.hspatcher;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import java.util.ArrayList;
import java.util.Random;

public class PatchArcadeView extends View {

    public interface OnScoreChangedListener {
        void onScoreChanged(int score, int streak, int bestStreak);
    }

    private static final int BASE_TARGETS = 4;
    private static final int EXTRA_TARGETS = 3;

    private final Paint framePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint gridPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint glowPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint corePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint pulsePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final RectF boardRect = new RectF();
    private final Random random = new Random();
    private final ArrayList<Target> targets = new ArrayList<>();

    private OnScoreChangedListener onScoreChangedListener;
    private boolean gameActive;
    private long lastFrameTime;
    private float patchIntensity;
    private int score;
    private int streak;
    private int bestStreak;

    public PatchArcadeView(Context context) {
        super(context);
        init();
    }

    public PatchArcadeView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public PatchArcadeView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        framePaint.setStyle(Paint.Style.STROKE);
        framePaint.setStrokeWidth(dp(1.5f));
        framePaint.setColor(0x66448AFF);

        gridPaint.setStyle(Paint.Style.STROKE);
        gridPaint.setStrokeWidth(dp(1f));
        gridPaint.setColor(0x22303A46);

        glowPaint.setStyle(Paint.Style.FILL);
        corePaint.setStyle(Paint.Style.FILL);
        pulsePaint.setStyle(Paint.Style.STROKE);
        pulsePaint.setStrokeWidth(dp(2f));

        setClickable(true);
    }

    public void setOnScoreChangedListener(OnScoreChangedListener listener) {
        onScoreChangedListener = listener;
        dispatchScore();
    }

    public void resetGame() {
        score = 0;
        streak = 0;
        bestStreak = 0;
        lastFrameTime = 0L;
        targets.clear();
        ensureTargets();
        dispatchScore();
        invalidate();
    }

    public void setGameActive(boolean active) {
        if (gameActive == active) return;
        gameActive = active;
        lastFrameTime = 0L;
        if (gameActive) {
            ensureTargets();
            postInvalidateOnAnimation();
        } else {
            invalidate();
        }
    }

    public void setPatchProgress(int progress) {
        patchIntensity = Math.max(0f, Math.min(1f, progress / 100f));
        ensureTargets();
        invalidate();
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        ensureTargets();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float padding = dp(6f);
        boardRect.set(padding, padding, getWidth() - padding, getHeight() - padding);
        canvas.drawRoundRect(boardRect, dp(14f), dp(14f), framePaint);
        drawGrid(canvas);

        if (gameActive) {
            updateTargets();
        }

        for (int i = 0; i < targets.size(); i++) {
            drawTarget(canvas, targets.get(i));
        }

        if (gameActive) {
            postInvalidateOnAnimation();
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!gameActive) return super.onTouchEvent(event);
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            handleTap(event.getX(), event.getY());
            invalidate();
            return true;
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    private void handleTap(float tapX, float tapY) {
        boolean hit = false;
        for (int i = targets.size() - 1; i >= 0; i--) {
            Target target = targets.get(i);
            float dx = tapX - target.x;
            float dy = tapY - target.y;
            if ((dx * dx) + (dy * dy) <= target.radius * target.radius * 1.5f) {
                score += 10 + (streak * 2);
                streak++;
                if (streak > bestStreak) bestStreak = streak;
                respawnTarget(target, true);
                hit = true;
                break;
            }
        }
        if (!hit) {
            streak = 0;
            score = Math.max(0, score - 3);
        }
        dispatchScore();
        performClick();
    }

    private void updateTargets() {
        long now = System.nanoTime();
        if (lastFrameTime == 0L) {
            lastFrameTime = now;
            return;
        }
        float deltaSeconds = Math.min(0.045f, (now - lastFrameTime) / 1_000_000_000f);
        lastFrameTime = now;

        float minX = boardRect.left + dp(18f);
        float maxX = boardRect.right - dp(18f);
        float minY = boardRect.top + dp(18f);
        float maxY = boardRect.bottom - dp(18f);
        float speedScale = 1f + (patchIntensity * 1.4f);

        ensureTargets();
        for (int i = 0; i < targets.size(); i++) {
            Target target = targets.get(i);
            target.phase += deltaSeconds * (2.8f + patchIntensity);
            target.x += target.vx * deltaSeconds * speedScale;
            target.y += target.vy * deltaSeconds * speedScale;

            if (target.x < minX || target.x > maxX) {
                target.vx = -target.vx;
                target.x = clamp(target.x, minX, maxX);
            }
            if (target.y < minY || target.y > maxY) {
                target.vy = -target.vy;
                target.y = clamp(target.y, minY, maxY);
            }
        }
    }

    private void drawGrid(Canvas canvas) {
        float colWidth = boardRect.width() / 6f;
        float rowHeight = boardRect.height() / 4f;
        for (int i = 1; i < 6; i++) {
            float x = boardRect.left + (colWidth * i);
            canvas.drawLine(x, boardRect.top, x, boardRect.bottom, gridPaint);
        }
        for (int i = 1; i < 4; i++) {
            float y = boardRect.top + (rowHeight * i);
            canvas.drawLine(boardRect.left, y, boardRect.right, y, gridPaint);
        }
    }

    private void drawTarget(Canvas canvas, Target target) {
        float pulse = 0.78f + (float) Math.sin(target.phase) * 0.22f;
        int glowAlpha = Math.min(255, (int) (80 + (100 * pulse)));
        int ringAlpha = Math.min(255, (int) (120 + (80 * pulse)));

        glowPaint.setColor(withAlpha(target.color, glowAlpha));
        corePaint.setColor(target.color);
        pulsePaint.setColor(withAlpha(target.color, ringAlpha));

        canvas.drawCircle(target.x, target.y, target.radius * 1.8f, glowPaint);
        canvas.drawCircle(target.x, target.y, target.radius, corePaint);
        canvas.drawCircle(target.x, target.y, target.radius * (1.45f + pulse * 0.2f), pulsePaint);
    }

    private void ensureTargets() {
        if (getWidth() <= 0 || getHeight() <= 0) return;
        int targetCount = BASE_TARGETS + Math.round(patchIntensity * EXTRA_TARGETS);
        while (targets.size() < targetCount) {
            targets.add(createTarget());
        }
        while (targets.size() > targetCount && !targets.isEmpty()) {
            targets.remove(targets.size() - 1);
        }
    }

    private Target createTarget() {
        Target target = new Target();
        respawnTarget(target, false);
        return target;
    }

    private void respawnTarget(Target target, boolean boosted) {
        float margin = dp(24f);
        target.radius = dp(10f + random.nextInt(8));
        target.x = margin + random.nextFloat() * Math.max(dp(40f), getWidth() - (margin * 2));
        target.y = margin + random.nextFloat() * Math.max(dp(40f), getHeight() - (margin * 2));
        float speed = dp(boosted ? 140f : 90f) + random.nextFloat() * dp(90f);
        double angle = random.nextDouble() * Math.PI * 2d;
        target.vx = (float) Math.cos(angle) * speed;
        target.vy = (float) Math.sin(angle) * speed;
        target.phase = random.nextFloat() * 6.2831855f;
        int[] colors = {0xFF00E676, 0xFFFFC107, 0xFF00BCD4, 0xFF448AFF, 0xFFFF5252};
        target.color = colors[random.nextInt(colors.length)];
    }

    private void dispatchScore() {
        if (onScoreChangedListener != null) {
            onScoreChangedListener.onScoreChanged(score, streak, bestStreak);
        }
    }

    private float clamp(float value, float min, float max) {
        if (value < min) return min;
        return Math.min(value, max);
    }

    private int withAlpha(int color, int alpha) {
        return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color));
    }

    private float dp(float value) {
        return value * getResources().getDisplayMetrics().density;
    }

    private static final class Target {
        float x;
        float y;
        float vx;
        float vy;
        float radius;
        float phase;
        int color;
    }
}