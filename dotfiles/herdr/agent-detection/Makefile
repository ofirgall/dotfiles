.PHONY: reload explain-all record-herdr-events stop-record-herdr-events

reload:
	herdr server reload-agent-manifests

explain-%:
	herdr agent explain $* --json

read-%:
	herdr agent read $* --source detection --format text

read-ansi-%:
	herdr agent read $* --source detection --format ansi

RECORD_ROOT := /tmp/herdr-detect-log
RECORD_PID := $(RECORD_ROOT)/recorder.pid

record-herdr-events:
	@mkdir -p $(RECORD_ROOT)
	@if [ -f $(RECORD_PID) ] && kill -0 $$(cat $(RECORD_PID)) 2>/dev/null; then \
		echo "already recording (pid $$(cat $(RECORD_PID))) -> $$(readlink $(RECORD_ROOT)/latest)"; exit 0; \
	fi; \
	dir=$(RECORD_ROOT)/$$(date +%Y%m%d-%H%M%S); mkdir -p $$dir; \
	nohup ../record-agent-detection.sh -o $$dir >$$dir/recorder.log 2>&1 & echo $$! >$(RECORD_PID); \
	ln -sfn $$dir $(RECORD_ROOT)/latest; \
	echo "recording (pid $$(cat $(RECORD_PID))) -> $$dir"; \
	echo "follow: tail -f $(RECORD_ROOT)/latest/recorder.log"

stop-record-herdr-events:
	@if [ -f $(RECORD_PID) ] && kill -TERM $$(cat $(RECORD_PID)) 2>/dev/null; then \
		echo "stopped (pid $$(cat $(RECORD_PID))), log in $$(readlink $(RECORD_ROOT)/latest)"; \
	else \
		echo "not recording"; \
	fi; \
	rm -f $(RECORD_PID)
