# ==============================================================================
# Script: gene_analysis.R
# ==============================================================================

# 1. إدخال البيانات وتسمية الـ Vectors
gene_names <- c("BRCA1", "TP53", "EGFR", "MYC", "PTEN", "KRAS")
control    <- c(5.2, 7.8, 3.1, 9.4, 6.0, 4.5)
treated    <- c(8.9, 7.6, 6.7, 12.1, 2.3, 9.8)

names(control) <- gene_names
names(treated) <- gene_names

# 2. حساب الـ Fold Change و Conditional Subsetting
fold_change <- round(treated / control, 3)
high_fc_genes <- fold_change[fold_change > 1.5]

# 3. بناء Matrix وحساب المتوسط بدون loops
expr_matrix <- cbind(Control = control, Treated = treated)
dimnames(expr_matrix) <- list(gene_names, c("Control", "Treated"))
mean_expression <- round(rowMeans(expr_matrix), 3)

# 4. التصنيف كـ Factor 
status_raw <- ifelse(
  fold_change > 1.2, 
  "upregulated",
  ifelse(fold_change < 0.8, "downregulated", "stable")
)

regulation_factor <- factor(
  status_raw,
  levels = c("upregulated", "stable", "downregulated")
)

# 5. بناء الـ Data Frame الأساسي
df <- data.frame(
  Gene            = gene_names,
  Control         = control,
  Treated         = treated,
  Mean_Expression = mean_expression,
  Fold_Change     = fold_change,
  Status          = regulation_factor,
  stringsAsFactors = FALSE
)

# 6. حفظ التقرير في results.txt
sink("results.txt")
cat("=====================================================\n")
cat("          GENE EXPRESSION ANALYSIS REPORT            \n")
cat("=====================================================\n\n")
print(df)
cat("\n--- Genes with Fold Change > 1.5 ---\n")
print(df[df$Fold_Change > 1.5, c("Gene", "Fold_Change")])
sink()

# ==============================================================================
# 7. الرسومات البيانية (هتظهر مباشرة في نافذة RStudio)
# ==============================================================================

# تنظيف الشاشة من أي رسومات قديمة معلقة
if (!is.null(dev.list())) dev.off()

# تقسيم شاشة العرض لعمودين عشان الرسمتين يظهروا جنب بعض
par(mfrow = c(1, 2), mar = c(5, 5, 4, 2))

# --- الرسم الأول: Grouped Barplot ---
mat_for_plot <- t(as.matrix(df[, c("Control", "Treated")]))
colnames(mat_for_plot) <- df$Gene

barplot(
  mat_for_plot,
  beside = TRUE,
  col = c("#4A90E2", "#E94E77"),
  main = "Control vs Treated Expression",
  xlab = "Genes",
  ylab = "Expression Level",
  ylim = c(0, max(c(df$Control, df$Treated)) + 2),
  las = 1
)
legend(
  "topleft", 
  legend = c("Control", "Treated"), 
  fill = c("#4A90E2", "#E94E77"), 
  bty = "n"
)
box()

# --- الرسم الثاني: Scatter Plot ---
status_colors <- c("upregulated" = "#D9534F", "stable" = "#6C757D", "downregulated" = "#0275D8")
point_colors  <- status_colors[as.character(df$Status)]

plot(
  df$Control, df$Treated,
  col = point_colors,
  pch = 19,
  cex = 1.8,
  main = "Treated vs Control Expression",
  xlab = "Control Expression",
  ylab = "Treated Expression",
  xlim = c(0, 14),
  ylim = c(0, 14),
  las = 1
)

abline(0, 1, col = "gray60")
text(df$Control, df$Treated, labels = df$Gene, pos = 4, font = 2, cex = 0.9)

legend(
  "topleft",
  legend = c("Upregulated", "Stable", "Downregulated"),
  fill = c("#D9534F", "#6C757D", "#0275D8"),
  bty = "n",
  cex = 0.9
)

# إرجاع العرض لشكله الطبيعي (رسمة واحدة)
par(mfrow = c(1, 1))

cat("Analysis complete. Check the 'Plots' pane in RStudio!\n")
