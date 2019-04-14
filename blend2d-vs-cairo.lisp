;;;; blend2d-vs-cairo.lisp 
;;
;; Copyright (c) 2019 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>


;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all copies.

;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

(in-package :blend2d-vs-cairo)

(defun random-lines-blend2d (count file-name &key (width 800) (height 800))
  (let ((img (autowrap:alloc 'bl:image-core))
        (ctx (autowrap:alloc 'bl:context-core))
        (line (autowrap:alloc 'bl:line)))
    (bl:image-init-as img width height bl:+format-prgb32+)
    (bl:context-init-as ctx img (cffi:null-pointer))
    (bl:context-set-comp-op ctx bl:+comp-op-src-copy+)
    (bl:context-fill-all ctx)
    (bl:context-set-comp-op ctx bl:+comp-op-src-over+)
    (dotimes (i count)
      (setf (bl:line.p0.x line) (random (coerce width 'double-float)))
      (setf (bl:line.p0.y line) (random (coerce height 'double-float)))
      (setf (bl:line.p1.x line) (random (coerce width 'double-float)))
      (setf (bl:line.p1.y line) (random (coerce height 'double-float)))
      (bl:context-set-stroke-style-rgba32 ctx (random #16rffffffff))
      (bl:context-stroke-geometry ctx bl:+geometry-type-line+ line))
    (bl:context-end ctx)
    (let ((codec (autowrap:alloc 'bl:image-codec-core)))
      (bl:image-codec-find-by-name codec (bl:image-codec-built-in-codecs) "BMP")
      (bl:image-write-to-file img (format nil file-name count) codec)
      (autowrap:free codec))
    (autowrap:free line)
    (autowrap:free img)
    (autowrap:free ctx)))

(defun random-lines-cairo (count file-name &key (width 800) (height 800))
  "Test writing a PNG file with Cairo."
  (cl-cairo2:with-png-file ((home-dir file-name) :argb32 width height)
    (cl-cairo2:set-source-rgba 0.0 0.0 0.0 1.0)
    (cl-cairo2:paint)
    (cl-cairo2:set-line-width 1.0)
    
    (dotimes (i count)
      (cl-cairo2:set-source-rgba (random 1.0) (random 1.0) (random 1.0) (random 1.0))
      (cl-cairo2:move-to (random width) (random height))
      (cl-cairo2:line-to (random width) (random height))
      (cl-cairo2:stroke))))


(defun random-circles-blend2d (count file-name &key (width 800) (height 800) (max-radius 80.0))
  (let ((img (autowrap:alloc 'bl:image-core))
        (ctx (autowrap:alloc 'bl:context-core))
        (circle (autowrap:alloc 'bl:circle)))
    (bl:image-init-as img width height bl:+format-prgb32+)
    (bl:context-init-as ctx img (cffi:null-pointer))
    (bl:context-set-comp-op ctx bl:+comp-op-src-copy+)
    (bl:context-fill-all ctx)
    (dotimes (i count)
      (let* ((sx (random (coerce width 'double-float)))
             (sy (random (coerce height 'double-float)))
             (radius (random max-radius)))
        (setf (bl:circle.cx circle) sx)
        (setf (bl:circle.cy circle) sy)
        (setf (bl:circle.r circle) radius)
        (bl:context-set-comp-op ctx bl:+comp-op-src-over+)
        (bl:context-set-fill-style-rgba32 ctx (random #16rffffffff))
        (bl:context-fill-geometry ctx bl:+geometry-type-circle+ circle)))
    (bl:context-end ctx)
    (let ((codec (autowrap:alloc 'bl:image-codec-core)))
      (bl:image-codec-find-by-name codec (bl:image-codec-built-in-codecs) "BMP")
      (bl:image-write-to-file img (format nil file-name count) codec)
      (autowrap:free codec))
    (autowrap:free circle)
    (autowrap:free img)
    (autowrap:free ctx)))

(defun random-circles-cairo (count file-name &key (width 800) (height 800) (max-radius 80.0))
  "Test writing a PNG file with Cairo."
 (cl-cairo2:with-png-file (file-name :argb32 width height)
    (cl-cairo2:set-source-rgba 0.0 0.0 0.0 1.0)
    (cl-cairo2:paint)
    (cl-cairo2:set-line-width 1.0)
    
    (dotimes (i count)
      (cl-cairo2:set-source-rgba (random 1.0) (random 1.0) (random 1.0) (random 1.0))
      (cl-cairo2:arc (random width) (random height) (random max-radius) 0 360)
      (cl-cairo2:fill-path))))


(defun time-function (fun)
  (let ((start-time (local-time:now)))
    (funcall fun)
    (local-time-duration:timestamp-difference (local-time:now) start-time)))

(defun compare-functions (output-directory name count f1 f2 width height)
  (let* ((file-name-1 (format nil "~a~a-~a-~a.bmp" output-directory name (car f1) count))
         (file-name-2 (format nil "~a~a-~a-~a.bmp" output-directory name (car f2) count))
         (result1 (time-function (curry (cdr f1) count file-name-1 :width width :height height)))
         (result2 (time-function (curry (cdr f2) count file-name-2 :width width :height height))))
    (format t "| ~a | ~a | ~a | ~a |~%"
            name
            count
            (local-time-duration:to-hhmmss result1)
            (local-time-duration:to-hhmmss result2))))

(defun run-benchmarks (output-directory)
  (let ((benchmarks (list
                     (list "random-circles"
                           (cons "blend2d" #'random-circles-blend2d)
                           (cons "cairo" #'random-circles-cairo))
                     (list "random-lines"
                           (cons "blend2d" #'random-lines-blend2d)
                           (cons "cairo" #'random-lines-cairo))))
        (counts '(50 500 5000 50000))
        (width 2560)
        (height 2560))
    (format t "| Name | Count | Blend2d | Cairo |~%")
    (dolist (current-bench benchmarks)
      (dolist (count counts)
        (compare-functions output-directory (car current-bench) count (second current-bench) (third current-bench) width height)))))
