#!/bin/bash

{
	cat feed.head

	for f in ./episodedata/s*.item; do
		cat "$f"
	done

	cat feed.end
} > feed.rss
