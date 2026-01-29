package utils

import "strings"

// TrimSpace - Trim whitespace from string
func TrimSpace(s string) string {
	return strings.TrimSpace(s)
}

// ToUpper - Convert string to uppercase
func ToUpper(s string) string {
	return strings.ToUpper(s)
}

// ToLower - Convert string to lowercase
func ToLower(s string) string {
	return strings.ToLower(s)
}

// IsEmpty - Check if string is empty
func IsEmpty(s string) bool {
	return TrimSpace(s) == ""
}
