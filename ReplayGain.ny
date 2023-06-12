;nyquist plug-in
;version 3
;type process
;name "ReplayGain"
;action "Calculating ReplayGain..."
;info "By Steve Daulton (http://easyspacepro.com).\nReleased under GPL v2.\n\nWARNING. Normalizing long tracks uses a lot of RAM.\nIf your computer does not have enough free memory\nNormalize may cause Audacity to freeze or crash.\n\nFor correct operation, apply to only one track at a time.\nThe 'Analyze' option is safe on long tracks.\n"

;; ReplayGain.ny by Steve Daulton Jan 2011.
;; Released under terms of the GNU General Public License version 2:
;; http://www.gnu.org/licenses/old-licenses/gpl-2.0.html .
;; Requires Audacity 1.3.4 or later.

;; Note: Calculated values may be different from
;; other implementations of ReplayGain due to
;; small differences in the equal loudness curve.

;control action "Normalize or Analyze" choice "Normalize,Analyze" 0  
;control amp "Adjust Normalized Output" real "dB" 0 -15 15


;;; equal loudness curve
(defun eqloud (s-in)
  (lowpass2
    (highpass2
      (eq-band
        (eq-band
          (eq-band
            (eq-lowshelf 
              (highpass2 
                (lowpass2 s-in 4000 0.9) 
              140 0.5)
            2200 -6 2)
          1400 -4 1)
        10000 -10 1)
      12000 14 0.7)
    20)
  16000))


;;; Loudness RMS
(defun Lrms (s-in)
  (let ((step-size (round (/ *sound-srate* 20.0))))
    (setf s-in (eqloud s-in))       ;filter with equal loudness curve
    (setf s-in (mult s-in s-in))    ;square of samples
    (if (arrayp s-in)
      ;;average of squares for stereo track
      (setf s-in (mult 0.5 (sum (aref s-in 0)(aref s-in 1)))))
    ;; compute RMS
    (s-sqrt (snd-avg s-in step-size step-size OP-AVERAGE))))

(cond
((>= *sound-srate* 44100)
    ;RMS level (50 ms window) limited to range 0 to -96 dB
    (if (= action 0)(setf s2 s))
    (setf s (s-max (db-to-linear -96)(clip (Lrms s) 1.0)))

    ;array for storing statistical data
    (setf levels (make-array 961))
    ;;; initialise array
    (dotimes (i 961)
      (setf (aref levels i) 0))
    ;;;
    (setq num-samples (1-               ;number of samples processed
      (do ((samp 1 (+ samp 1)) 
           (sval (snd-fetch s) (setq sval (snd-fetch s))))
          ((not sval) samp)
        (setq sval                      ;dB value x 10
             (abs (round (* 10.0 (linear-to-db sval)))))
        ;increment array element for dB value
        (setf (aref levels sval)(1+ (aref levels sval))))))

    ;(print levels)
    ;;; OUTPUT TO DEBUG WINDOW
    ;; (dotimes (i 961)
    ;;  (format T "Number of occurances at -~a dB: ~a~%" i (aref levels i)))

    (setq target (* num-samples 0.95))
    (setq SumSamp 0)

    (setq *float-format* "%1.1f")

    (setq RG
      (* 0.1
        (-
          (do ((i 960 (setq i (1- i))))
              ((>= SumSamp target) i)
            (setq SumSamp (+ SumSamp (aref levels i))))
          256)))

    (setq sign (if (> RG 0) "+" ""))
    (if (> RG 70)
      (format nil "Error.~%Audio level too low.")
      (if (= action 0)
        (mult s2 (/ (db-to-linear amp)(db-to-linear (- RG))))
        (format nil "ReplayGain level: ~a~a dB.~%" sign RG))))
(t "Track sample rate must be 44100 Hz or higher"))
