package in.startv.hspatcher;

import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.OvershootInterpolator;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public class CreditsActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        applyModernSystemUi();
        buildUi();
    }

    private void applyModernSystemUi() {
        try {
            getWindow().setStatusBarColor(getColor(R.color.hsp_bg));
            getWindow().setNavigationBarColor(getColor(R.color.hsp_bg));

            View decorView = getWindow().getDecorView();
            int flags = decorView.getSystemUiVisibility();
            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
            decorView.setSystemUiVisibility(flags);
        } catch (Throwable ignored) {
        }
    }

    private void buildUi() {
        ScrollView root = new ScrollView(this);
        root.setFillViewport(true);
        root.setBackgroundResource(R.drawable.bg_glass_root);

        LinearLayout main = new LinearLayout(this);
        main.setOrientation(LinearLayout.VERTICAL);
        main.setPadding(dp(18), dp(18), dp(18), dp(24));

        LinearLayout topRow = new LinearLayout(this);
        topRow.setOrientation(LinearLayout.HORIZONTAL);
        topRow.setGravity(Gravity.CENTER_VERTICAL);

        Button backBtn = makeButton("←", getColor(R.color.hsp_surface));
        backBtn.setTextSize(20f);
        backBtn.setOnClickListener(v -> finish());
        topRow.addView(backBtn, new LinearLayout.LayoutParams(dp(48), dp(48)));

        TextView badge = chip("CREDITS", R.color.hsp_accent_amber);
        LinearLayout.LayoutParams badgeLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        badgeLp.leftMargin = dp(12);
        topRow.addView(badge, badgeLp);

        main.addView(topRow);

        TextView title = new TextView(this);
        title.setText("Built With Real Tools");
        title.setTextSize(30f);
        title.setTypeface(null, Typeface.BOLD);
        title.setTextColor(getColor(R.color.hsp_text));
        title.setPadding(0, dp(14), 0, dp(4));
        main.addView(title);

        TextView sub = new TextView(this);
        sub.setText("HSPatcher 3.59 combines Play Store downloads, split merge, Frida-based patching, persistent signing, patched-app updates, and installer flow in one app.");
        sub.setTextSize(13f);
        sub.setTextColor(getColor(R.color.hsp_text_muted));
        sub.setLineSpacing(0f, 1.1f);
        main.addView(sub);

        TextView hero = new TextView(this);
        hero.setText("Thanks to the upstream projects and reverse-engineering tools that make the workflow possible.");
        hero.setTextSize(12f);
        hero.setTextColor(getColor(R.color.hsp_text));
        hero.setBackgroundResource(R.drawable.bg_tools_option);
        hero.setPadding(dp(14), dp(12), dp(14), dp(12));
        LinearLayout.LayoutParams heroLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        heroLp.topMargin = dp(14);
        main.addView(hero, heroLp);

        main.addView(sectionCard(
            "Core Stack",
            "Google Play download",
            "rehmatworks/gplaydl via Aurora-style anonymous Play auth and FDFE delivery",
            "Split merge",
            "REAndroid ARSCLib powers .apks/.xapk/.apkm merge and manifest cleanup",
            "APK signing",
            "Google apksig signs patched outputs with v1 + v2 + v3 schemes"
        ));

        main.addView(sectionCard(
            "Runtime Patching",
            "Frida gadget",
            "Embedded Frida gadget and Java bridge bootstrap runtime hooks",
            "Signature handling",
            "Original certificate extraction plus persistent patcher signing key for update-safe installs",
            "Bundle processing",
            "Play downloads, asset filtering, split merge, and auto-patch flow integrated in-app"
        ));

        main.addView(sectionCard(
            "Project Credits",
            "Aurora / Play ecosystem",
            "Anonymous auth and Play delivery research that made direct device downloads practical",
            "REAndroid",
            "Resource and manifest merge foundation used for split APK reconstruction",
            "apksig + Android platform tools",
            "Reliable signing, zipalign, and package installation validation"
        ));

        TextView footer = new TextView(this);
        footer.setText("Respect upstream licenses when redistributing builds or bundled tooling.");
        footer.setTextSize(11f);
        footer.setTextColor(getColor(R.color.hsp_text_faint));
        footer.setGravity(Gravity.END);
        LinearLayout.LayoutParams footerLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        footerLp.topMargin = dp(18);
        main.addView(footer, footerLp);

        root.addView(main);
        setContentView(root);
        animateIntro(main, title, hero);
    }

    private LinearLayout sectionCard(String sectionTitle,
                                     String title1, String body1,
                                     String title2, String body2,
                                     String title3, String body3) {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setBackgroundResource(R.drawable.bg_card);
        card.setPadding(dp(16), dp(16), dp(16), dp(16));

        LinearLayout.LayoutParams cardLp = new LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        cardLp.topMargin = dp(14);
        card.setLayoutParams(cardLp);

        TextView label = new TextView(this);
        label.setText(sectionTitle.toUpperCase());
        label.setTextSize(11f);
        label.setTypeface(null, Typeface.BOLD);
        label.setTextColor(getColor(R.color.hsp_accent_teal));
        card.addView(label);

        card.addView(item(title1, body1));
        card.addView(item(title2, body2));
        card.addView(item(title3, body3));
        return card;
    }

    private LinearLayout item(String title, String body) {
        LinearLayout item = new LinearLayout(this);
        item.setOrientation(LinearLayout.VERTICAL);
        item.setPadding(0, dp(12), 0, 0);

        TextView titleView = new TextView(this);
        titleView.setText(title);
        titleView.setTextSize(16f);
        titleView.setTypeface(null, Typeface.BOLD);
        titleView.setTextColor(getColor(R.color.hsp_text));
        item.addView(titleView);

        TextView bodyView = new TextView(this);
        bodyView.setText(body);
        bodyView.setTextSize(12f);
        bodyView.setTextColor(getColor(R.color.hsp_text_muted));
        bodyView.setLineSpacing(0f, 1.1f);
        bodyView.setPadding(0, dp(4), 0, 0);
        item.addView(bodyView);
        return item;
    }

    private TextView chip(String text, int colorRes) {
        TextView chip = new TextView(this);
        chip.setText(text);
        chip.setTextSize(10f);
        chip.setTypeface(null, Typeface.BOLD);
        chip.setTextColor(getColor(colorRes));
        chip.setBackgroundResource(R.drawable.bg_chip);
        chip.setPadding(dp(10), dp(4), dp(10), dp(4));
        return chip;
    }

    private Button makeButton(String text, int color) {
        Button button = new Button(this);
        button.setText(text);
        button.setTextColor(getColor(R.color.hsp_text));
        button.setBackgroundResource(R.drawable.btn_surface);
        button.setAllCaps(false);
        return button;
    }

    private void animateIntro(View main, View title, View hero) {
        try {
            main.setAlpha(0f);
            main.setTranslationY(dp(24));
            main.animate().alpha(1f).translationY(0f)
                .setDuration(340)
                .setInterpolator(new DecelerateInterpolator())
                .start();

            title.setScaleX(0.94f);
            title.setScaleY(0.94f);
            title.animate().scaleX(1f).scaleY(1f)
                .setDuration(420)
                .setInterpolator(new OvershootInterpolator(0.7f))
                .start();

            hero.setAlpha(0f);
            hero.animate().alpha(1f)
                .setStartDelay(120)
                .setDuration(360)
                .start();
        } catch (Throwable ignored) {
        }
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}