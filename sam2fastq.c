#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define LINE_SIZE 4096
#define TAG_SIZE 256

// 函数：安全地提取特定标签的值
bool extract_tag_value(char *line, const char *tagPrefix, char *tagValue) {
    char *start = strstr(line, tagPrefix);
    if (!start) return false; // 标签不存在
    start += strlen(tagPrefix); // 跳过标签前缀

    char *end = strchr(start, '\t'); // 查找标签值的结尾
    if (!end) end = line + strlen(line); // 如果这是最后一个标签

    size_t len = end - start;
    if (len >= TAG_SIZE) len = TAG_SIZE - 1; // 确保不会溢出
    strncpy(tagValue, start, len);
    tagValue[len] = '\0'; // 确保字符串正确终结

    return true;
}

// 主函数
int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <input SAM file> <output FASTQ file>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *inputPath = argv[1];
    char *outputPath = argv[2];
    FILE *inputFile = fopen(inputPath, "r");
    FILE *outputFile = fopen(outputPath, "w");

    if (!inputFile || !outputFile) {
        fprintf(stderr, "Error opening files\n");
        return EXIT_FAILURE;
    }

    char line[LINE_SIZE];
    int totalReads = 0, convertedReads = 0, skippedReads = 0;
    char rgTag[TAG_SIZE], cbTag[TAG_SIZE], ubTag[TAG_SIZE];

    while (fgets(line, LINE_SIZE, inputFile)) {
        if (line[0] == '@') {
            skippedReads++;
            continue;
        }
        totalReads++;

        bool rgFound = extract_tag_value(line, "RG:Z:", rgTag);
        bool cbFound = extract_tag_value(line, "CB:Z:", cbTag);
        bool ubFound = extract_tag_value(line, "UB:Z:", ubTag);

        if (!rgFound || !cbFound || !ubFound) {
            skippedReads++;
            continue;
        }

        char qname[TAG_SIZE], seq[TAG_SIZE], qual[TAG_SIZE];
        sscanf(line, "%s\t%*s\t%*s\t%*s\t%*s\t%*s\t%*s\t%*s\t%*s\t%s\t%s", qname, seq, qual);
        fprintf(outputFile, "@%s&RG:%s&_%s_%s\n%s\n+\n%s\n", qname, rgTag, cbTag, ubTag, seq, qual);
        convertedReads++;
    }

    fclose(inputFile);
    fclose(outputFile);

    printf("\nConversion complete.\n");
    printf("Total reads processed (excluding headers): %d\n", totalReads);
    printf("Reads converted: %d\n", convertedReads);
    printf("Reads skipped due to missing information: %d\n", skippedReads);

    return EXIT_SUCCESS;
}
