.PHONY: reload explain-all

reload:
	herdr server reload-agent-manifests

explain-%:
	herdr agent explain $* --json

read-%:
	herdr agent read $* --source detection --format text

read-ansi-%:
	herdr agent read $* --source detection --format ansi
