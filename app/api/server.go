package main

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type (
	user struct {
		ID   int    `json:"id"`
		Name string `json:"name"`
	}
)

var (
	users = map[int]*user{}
	seq   = 1
)

//----------
// Handlers
//----------

func health(c echo.Context) error {
	return c.String(http.StatusOK, "OK")
}

func createUser(c echo.Context) error {
	u := &user{
		ID: seq,
	}
	if err := c.Bind(u); err != nil {
		return err
	}
	users[u.ID] = u
	seq++
	return c.JSONPretty(http.StatusCreated, u, "  ")
}

func getUser(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	return c.JSONPretty(http.StatusOK, users[id], "  ")
}

func updateUser(c echo.Context) error {
	u := new(user)
	if err := c.Bind(u); err != nil {
		return err
	}
	id, _ := strconv.Atoi(c.Param("id"))
	users[id].Name = u.Name
	return c.JSONPretty(http.StatusOK, users[id], "  ")
}

func deleteUser(c echo.Context) error {
	id, _ := strconv.Atoi(c.Param("id"))
	delete(users, id)
	return c.NoContent(http.StatusNoContent)
}

func getAllUsers(c echo.Context) error {
	values := []*user{}
	for _, value := range users {
		values = append(values, value)
	}
	return c.JSONPretty(http.StatusOK, values, "  ")
}

func main() {
	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORS())

	// Routes
	e.GET("/health", health)
	e.GET("/api/users", getAllUsers)
	e.POST("/api/users", createUser)
	e.GET("/api/users/:id", getUser)
	e.PUT("/api/users/:id", updateUser)
	e.DELETE("/api/users/:id", deleteUser)

	// Start server
	e.Logger.Fatal(e.Start(":8887"))
}
