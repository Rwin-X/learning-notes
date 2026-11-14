# رگرسیون خطی ساده: داده را بگیر، رگرسیون را حساب کن، نمودار را نشان بده
#
# روش اجرا (داخل R یا RStudio):
#   source("simple_regression_plot_fa.R")
# (یا در RStudio روی دکمه‌ی Source بزنید)

# ---- 1. گرفتن داده ----
# اعداد را با فاصله یا ویرگول وارد کنید. gsub ویرگول‌ها را به فاصله تبدیل می‌کند
# و scan متن را به عدد تبدیل می‌کند.
x <- scan(text = gsub(",", " ", readline("Enter the x values: ")), quiet = TRUE)
y <- scan(text = gsub(",", " ", readline("Enter the y values: ")), quiet = TRUE)

# ---- 2. بررسی داده ----
# تعداد x و y باید برابر باشد و حداقل 3 جفت داده لازم است.
if (length(x) != length(y) || length(x) < 3) {
  stop("x and y need the same number of values (at least 3).")
}

# ---- 3. محاسبه ----
# lm مدل خطی y بر حسب x را می‌سازد و summary نتایج را چاپ می‌کند.
model <- lm(y ~ x)
print(summary(model))

# ---- 4. نمودار ----
# عرض از مبدأ و شیب را از مدل می‌گیریم تا روی نمودار بنویسیم.
a <- coef(model)[1]                       # عرض از مبدأ
b <- coef(model)[2]                       # شیب خط
sign_text <- if (b < 0) "-" else "+"      # علامت شیب برای نوشتن درست فرمول
formula_text <- sprintf("y = %.3f %s %.3f x", a, sign_text, abs(b))
slope_text <- sprintf("Slope = %.3f", b)

# محدوده‌ی محور y را در بالا 25 درصد بزرگ‌تر می‌کنیم تا بالای نمودار
# جای خالی برای نوشتن فرمول و شیب داشته باشد.
y_top <- max(y) + 0.25 * (max(y) - min(y))

# نقاط داده را رسم می‌کند و سپس خط رگرسیون را روی آن می‌کشد.
plot(x, y, pch = 19, col = "steelblue", main = "Regression plot",
     ylim = c(min(y), y_top))
abline(model, col = "red", lwd = 2)

# فرمول و شیب را داخل خود نمودار و در بالای آن می‌نویسد.
# برای شیب مثبت بالا-چپ و برای شیب منفی بالا-راست (جایی که خط نمی‌گذرد).
corner <- if (b < 0) "topright" else "topleft"
legend(corner, legend = c(formula_text, slope_text),
       bg = "white", cex = 1.1, text.font = 2, x.intersp = -0.5)
