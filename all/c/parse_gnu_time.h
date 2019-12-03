#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

char *gnu_time_metrics_list[] = {
  "peak_rss",
  "peak_rss_kbytes",
  "runtime_seconds",
  "runtime",
  NULL
};

typedef struct gnu_time_metrics {
  double peak_rss; /* In GB */
  size_t peak_rss_kbytes;
  size_t runtime_seconds;
} gnu_time_metrics;

void parse_gnu_time(FILE *file, gnu_time_metrics *info) {
  size_t tmp, tmp2;
  float tmp_f;
  char *line;
  size_t len;
  ssize_t read;

  line = NULL;
  len = 0;
  while(read = getline(&line, &len, file) != -1) {
    if(sscanf(line, "  Maximum resident set size (kbytes): %zu", &tmp) == 1) {
      info->peak_rss_kbytes = tmp;
      info->peak_rss = ((double)tmp) / ((double)1024) / ((double)1024);
      goto cleanup;
    } else if(sscanf(line, "   Elapsed (wall clock) time (h:mm:ss or m:ss): %zu:%zu:%f", &tmp, &tmp2, &tmp_f) == 3) {
      info->runtime_seconds = (tmp * 60 * 60) + (tmp2 * 60) + ((size_t) tmp_f);
    } else if(sscanf(line, "   Elapsed (wall clock) time (h:mm:ss or m:ss): %zu:%f", &tmp, &tmp_f) == 2) {
      if(tmp_f < 0) {
        /* Just to make sure the below explicit cast from float->size_t is valid */
        fprintf(stderr, "Number of seconds from GNU time was negative. Aborting.\n");
        exit(1);
      }
      info->runtime_seconds = (tmp * 60) + ((size_t) tmp_f);
    }
  }

cleanup:
  free(line);
  return;
}

gnu_time_metrics *init_gnu_time_metrics() {
  gnu_time_metrics *info;
  info = malloc(sizeof(gnu_time_metrics));

  info->peak_rss_kbytes = 0;
  info->peak_rss = 0.0;
  info->runtime_seconds = 0;

  return info;
}

char *is_gnu_time_metric(char *metric) {
  char *ptr, *filename;
  int i;

  i = 0;
  while((ptr = gnu_time_metrics_list[i]) != NULL) {
    if(strcmp(metric, ptr) == 0) {
      filename = malloc(sizeof(char) * (strlen("stdout.txt") + 1));
      strcpy(filename, "stdout.txt");
      return filename;
    }
    i++;
  }

  return NULL;
}

void print_gnu_time_metric(char *metric, gnu_time_metrics *info) {
  if(strcmp(metric, "peak_rss") == 0) {
    printf("%lf", info->peak_rss);
  } else if(strcmp(metric, "peak_rss_kbytes") == 0) {
    printf("%zu", info->peak_rss_kbytes);
  } else if(strcmp(metric, "runtime") == 0) {
    printf("%zu", info->runtime_seconds);
  } else if(strcmp(metric, "runtime_seconds") == 0) {
    printf("%zu", info->runtime_seconds);
  }
}
