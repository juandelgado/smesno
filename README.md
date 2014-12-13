# GIF-O-MATIC

Stitch your funnies together for the ultimate lulz.

Basically, given a set of images and videos they are combined into a single video meant to be played fullscreen on a loop.

On purpose all files are resized to the same size and the quality is not particularly high, it gives the final output that extra level of cheesiness.

## Installation

Requires ffmpeg, ImageMagic:

```sudo port install ffmpeg
sudo port install ImageMagick```

Then:

```bundle install```

## Usage

```ruby main -i /path/to/folder_with_funnies -o /path/to/output.mpg```
