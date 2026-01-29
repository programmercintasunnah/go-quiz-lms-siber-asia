package validator

import (
	"github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
	validate = validator.New()
}

// Validate - Validate struct
func Validate(data interface{}) error {
	return validate.Struct(data)
}

// ValidateVar - Validate single variable
func ValidateVar(field interface{}, tag string) error {
	return validate.Var(field, tag)
}
