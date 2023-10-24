/*
Copyright © 2023 Julian Easterling julian@julianscorner.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

var imageVersion string

func main() {
	name := strings.ReplaceAll(filepath.Base(os.Args[0]), ".exe", "")
	args := os.Args[1:]

	pwd, _ := os.Getwd()

	keys, f := os.LookupEnv("USER_ANSIBLE_KEYS")
	if !f {
		if runtime.GOOS == "windows" {
			keys = fmt.Sprintf("%s/.ssh/wsl", os.Getenv("USERPROFILE"))
		} else {
			home, _ := os.UserHomeDir()
			keys = fmt.Sprintf("%s/.ssh", home)
		}
	}

	data := strings.ReplaceAll(fmt.Sprintf("%s:/home/ansible/data", pwd), "\\", "/")
	ssh := strings.ReplaceAll(fmt.Sprintf("%s:/ssh", keys), "\\", "/")

	binary := fmt.Sprintf("/home/ansible/.local/ansible/bin/%s", name)

	docker := []string{
		"run",
		"--rm",
		"-it",
	}

	for _, e := range os.Environ() {
		if strings.HasPrefix(e, "ANSIBLE") {
			docker = append(docker, "-e")
			docker = append(docker, e)
		}
	}

	docker = append(docker, "-v")
	docker = append(docker, ssh)
	docker = append(docker, "-v")
	docker = append(docker, data)

	image, f := os.LookupEnv("USER_ANSIBLE_IMAGE")
	if !f {
		image = fmt.Sprintf("dcjulian29/ansible:%s", imageVersion)
	}

	docker = append(docker, image)
	docker = append(docker, binary)
	docker = append(docker, args...)

	cmd := exec.Command("docker", docker...)
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout

	if err := cmd.Run(); err != nil {
		fmt.Printf("\033[1;31m%s\033[0m\n", err)
		os.Exit(1)
	}

	os.Exit(0)
}
