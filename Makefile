EMACS ?= emacs

all: compile

compile:
	@test -d stream-2.2.4 || (wget 'https://elpa.gnu.org/packages/stream-2.2.4.tar' && tar xvf stream-2.2.4.tar)
	${EMACS} -Q --batch -L stream-2.2.4 -L . --eval "(setq byte-compile-error-on-warn t)" -f batch-byte-compile countdown.el

xuchunyang:
	@for cmd in emacs-25.1 emacs-25.3 emacs-26.1 emacs-26.2; do \
	    command -v $$cmd && make EMACS=$$cmd ;\
	done
