package main

import (
	"testing"
	"github.com/stretchr/testify/assert"
	"net/http/httptest"

	"net/http"
	"github.com/labstack/echo/v4"
)

func TestHealth(t *testing.T) {
	// test that the health function returns a status of 200

}

func TestHealthEndpoint(t *testing.T) {
    e := echo.New()

	req := httptest.NewRequest(http.MethodGet, "/health", nil)
    rec := httptest.NewRecorder()
    c := e.NewContext(req, rec)
    // Call the handler function
    if assert.NoError(t, health(c)) {
        assert.Equal(t, http.StatusOK, rec.Code)
        assert.Equal(t, "OK", rec.Body.String())
    }
}