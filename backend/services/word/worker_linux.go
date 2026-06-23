//go:build !windows

package word

// RunOnCOMThread on Linux runs fn directly — no COM thread setup needed.
func RunOnCOMThread(fn func() error) error {
	return fn()
}
