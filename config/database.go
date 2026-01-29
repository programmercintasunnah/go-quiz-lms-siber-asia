package config

import "fmt"

// GetConnectionString - Generate SQL Server connection string
func (c *DatabaseConfig) GetConnectionString() string {
	return fmt.Sprintf(
		"server=%s;port=%s;user id=%s;password=%s;database=%s;encrypt=disable",
		c.Host,
		c.Port,
		c.User,
		c.Password,
		c.DBName,
	)
}
