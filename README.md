# blend2d-vs-cairo
### _Jeremiah LaRocco <jeremiah_larocco@fastmail.com>_

This is a collection of benchmarks comparing the performance of [cl-cairo2](https://github.com/rpav/cl-cairo2) and [blend2d](https://github.com/jl2/cl-blend2d).

For more information see [project.org](project.org).

## Summary Results

| Task           | Count |  Blend2d |    Cairo |
|----------------|-------|----------|----------|
| random-circles |    50 | 00:00:00 | 00:00:00 |
| random-circles |   500 | 00:00:00 | 00:00:01 |
| random-circles |  5000 | 00:00:00 | 00:00:15 |
| random-circles | 50000 | 00:00:02 | 00:02:29 |
| random-lines   |    50 | 00:00:00 | 00:00:00 |
| random-lines   |   500 | 00:00:00 | 00:00:00 |
| random-lines   |  5000 | 00:00:00 | 00:00:02 |
| random-lines   | 50000 | 00:00:06 | 00:00:13 |



## License

ISC


Copyright (c) 2019 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>


