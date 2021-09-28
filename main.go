package main

import (
	"context"
	"errors"
	"fmt"
	gin "github.com/gin-gonic/gin"
	metacall "github.com/metacall/core/source/ports/go_port/source"
	"log"
	"net/http"
	"os"
	"time"
)

func DeployTransactionPy(transferId int, transfer_amount int) (string, error) {
	ret, err := metacall.Call("deploy_transaction_py", transferId, transfer_amount)

	if err != nil {
		return "", err
	}

	if ret, ok := ret.(string); ok {
		return ret, nil
	} else {
		return "", errors.New("An error ocurred after executing the call when casting the result.")
	}
}

func DeployTransactionTs(transferId int, transfer_amount int) (float64, error) {
	ret, err := metacall.Call("deploy_transaction_ts", transferId, transfer_amount)

	if err != nil {
		return 0.0, err
	}

	if ret, ok := ret.(float64); ok {
		return ret, nil
	} else {
		return 0.0, errors.New("An error ocurred after executing the call when casting the result.")
	}
}

func main() {

	// Initialize MetaCall
	if err := metacall.Initialize(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Defer MetaCall destruction
	defer metacall.Destroy()

	scripts := []string{"script.py"}

	if err := metacall.LoadFromFile("py", scripts); err != nil {
		fmt.Println(err)
		return
	}

	scripts = []string{"script.ts"}

	if err := metacall.LoadFromFile("ts", scripts); err != nil {
		fmt.Println(err)
		return
	}

	r := gin.Default()

	srv := &http.Server{
		Addr:    ":8080",
		Handler: r,
	}

	r.GET("/deploy_transaction_py", func(c *gin.Context) {
		result, err := DeployTransactionPy(30, 50)

		if err != nil {
			c.JSON(400, gin.H{
				"Error": err.Error(),
			})
		} else {
			c.JSON(200, gin.H{
				"Deployment Status": result,
			})
		}
	})

	r.GET("/deploy_transaction_ts", func(c *gin.Context) {
		result, err := DeployTransactionTs(30, 50)

		if err != nil {
			c.JSON(400, gin.H{
				"Error": err.Error(),
			})
		} else {
			c.JSON(200, gin.H{
				"Deployment Status": result,
			})
		}
	})

	r.GET("/close", func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := srv.Shutdown(ctx); err != nil {
			log.Fatal("Server Shutdown:", err)
		}
	})

	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal("Listen:", err)
	}
}
