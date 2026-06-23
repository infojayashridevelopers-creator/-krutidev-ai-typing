package models

import (
	"time"
)

type User struct {
	ID           uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	Name         string    `gorm:"not null" json:"name"`
	Email        string    `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash string    `gorm:"not null" json:"-"`
	CreatedAt    time.Time `json:"created_at"`
}

type Template struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID    uint      `gorm:"not null" json:"user_id"`
	Name      string    `gorm:"not null" json:"name"`
	FilePath  string    `json:"file_path"`
	Category  string    `json:"category"`
	CreatedAt time.Time `json:"created_at"`
	User      User      `gorm:"foreignKey:UserID" json:"-"`
}

type Setting struct {
	ID     uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID uint   `gorm:"not null" json:"user_id"`
	Key    string `gorm:"not null" json:"key"`
	Value  string `json:"value"`
	User   User   `gorm:"foreignKey:UserID" json:"-"`
}

type Log struct {
	ID        uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID    uint      `gorm:"not null" json:"user_id"`
	Action    string    `json:"action"`
	Timestamp time.Time `json:"timestamp"`
	User      User      `gorm:"foreignKey:UserID" json:"-"`
}

type WordSettings struct {
	FontName         string  `json:"font_name"`
	FontSize         float64 `json:"font_size"`
	Alignment        string  `json:"alignment"`
	LineSpacing      float64 `json:"line_spacing"`
	SpaceBefore      float64 `json:"space_before"`
	SpaceAfter       float64 `json:"space_after"`
	Bold             bool    `json:"bold"`
	Italic           bool    `json:"italic"`
	Underline        bool    `json:"underline"`
}

func DefaultWordSettings() WordSettings {
	return WordSettings{
		FontName:    "Kruti Dev 010",
		FontSize:    14,
		Alignment:   "justify",
		LineSpacing: 1.15,
		SpaceBefore: 6,
		SpaceAfter:  6,
	}
}
