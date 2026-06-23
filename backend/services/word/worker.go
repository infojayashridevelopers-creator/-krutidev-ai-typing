//go:build windows

package word

import (
	"runtime"

	"github.com/go-ole/go-ole"
)

type comRequest struct {
	fn     func() error
	result chan<- error
}

var comQueue = make(chan comRequest, 64)

func init() {
	ready := make(chan struct{})
	go func() {
		runtime.LockOSThread()
		ole.CoInitialize(0)
		close(ready)
		for req := range comQueue {
			req.result <- req.fn()
		}
	}()
	<-ready
}

// RunOnCOMThread executes fn synchronously on the single OS thread that has
// CoInitialize called. All go-ole / Word COM calls must go through here.
func RunOnCOMThread(fn func() error) error {
	ch := make(chan error, 1)
	comQueue <- comRequest{fn: fn, result: ch}
	return <-ch
}
