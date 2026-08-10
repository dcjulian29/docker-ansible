/*
Copyright © 2026 Julian Easterling

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
	"path/filepath"
	"strings"

	"github.com/dcjulian29/go-toolbox/docker"
	"github.com/dcjulian29/go-toolbox/textformat"
)

var imageVersion string

func main() {
	name := strings.ReplaceAll(filepath.Base(os.Args[0]), ".exe", "")
	args := os.Args[1:]

	pwd, err := os.Getwd()
	if err != nil {
		fmt.Println(textformat.Fatal(err.Error()))
		os.Exit(1)
	}

	binary := fmt.Sprintf("/home/ansible/.local/ansible/bin/%s", name)

	if name == "ansible-shell" {
		binary = "bash"
		args = nil
	}

	image, tag := imageReference()

	opts := docker.ContainerOptions{
		AdditionalArgs:       args,
		Command:              binary,
		EnvironmentVariables: environmentVariables(),
		Image:                image,
		Interactive:          true,
		Tag:                  tag,
		Volumes: []string{
			unixPath(fmt.Sprintf("%s:/ssh", sshKeyDirectory())),
			unixPath(fmt.Sprintf("%s:/home/ansible/data", pwd)),
		},
	}

	if _, err := docker.Run(opts); err != nil {
		fmt.Println(textformat.Fatal(err.Error()))
		os.Exit(1)
	}
}

// environmentVariables collects the host environment variables the container
// needs, keeping the prefixes the image expects.
func environmentVariables() map[string]string {
	env := docker.EnvironmentVariablesWithPrefix("ANSIBLE")

	for key, value := range docker.EnvironmentVariablesWithPrefix("K8S") {
		env[key] = value
	}

	return env
}

// imageReference returns the image and tag to run, honoring the
// USER_ANSIBLE_IMAGE override which may or may not carry its own tag.
func imageReference() (string, string) {
	image, found := os.LookupEnv("USER_ANSIBLE_IMAGE")
	if !found {
		return "dcjulian29/ansible", imageVersion
	}

	// A colon only introduces the tag when it comes after the last path
	// separator; before it, the colon belongs to a registry port such as
	// "registry:5000/image".
	if i := strings.LastIndex(image, ":"); i > strings.LastIndex(image, "/") {
		return image[:i], image[i+1:]
	}

	return image, imageVersion
}

// sshKeyDirectory returns the host directory holding the SSH keys to mount.
func sshKeyDirectory() string {
	keys, found := os.LookupEnv("USER_ANSIBLE_KEYS")
	if found {
		return keys
	}

	home, _ := os.UserHomeDir()

	return fmt.Sprintf("%s/.ssh", home)
}

func unixPath(path string) string {
	return strings.ReplaceAll(path, "\\", "/")
}
