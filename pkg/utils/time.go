package utils

import "time"

// Now - Get current time
func Now() time.Time {
	return time.Now()
}

// IsWithinRange - Check if current time is within start and end time
func IsWithinRange(start, end time.Time) bool {
	now := Now()
	return now.After(start) && now.Before(end)
}

// AddMinutes - Add minutes to time
func AddMinutes(t time.Time, minutes int) time.Time {
	return t.Add(time.Duration(minutes) * time.Minute)
}

// FormatDateTime - Format time to datetime string
func FormatDateTime(t time.Time) string {
	return t.Format("2006-01-02 15:04:05")
}
