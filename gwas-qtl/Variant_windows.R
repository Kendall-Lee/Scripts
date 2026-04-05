#peanut graph window 
setwd("/Users/kendalllee/Documents")

#upload data created with bedtools_windows.sh script
df <- read.table("coverage_with_header.txt", header=TRUE, sep="\t") 
hist(df$variant_count, breaks=50, main="Variant density per window", xlab="Variant count")
summary(df$variant_count)
quantile(df$variant_count, probs = c(0.95, 0.99, 0.999))


# Find threshold from earlier
high_threshold <- quantile(df$variant_count, 0.999)

# Filter windows above this threshold
high_variant_windows <- df[df$variant_count > high_threshold, ]

# View some egregious examples
head(high_variant_windows[order(-high_variant_windows$variant_count), ])