package test

import (
	"os"
	"testing"

	networkingv1 "k8s.io/api/networking/v1"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
)

func TestIngressTemplateClassName(t *testing.T) {

	var values = []struct {
		ingressClassName    string
		deprecatedClassName string
		expectedIngress     string
	}{
		{"nginx", "nginx-dep", "nginx"},
		{"nginx", "", "nginx"},
		{"", "nginx-dep", "nginx-dep"},
	}

	var templates = []struct {
		templateFile       string
		ingressClassKey    string
		deprecatedClassKey string
	}{
		{"templates/ingress.yaml", "ingress.ingressClassName", "ingressClassName"},
		{"templates/ingress-grpc.yaml", "grpcIngress.ingressClassName", "ingress.className"},
	}

	helmChartPath := "../"

	os.Stdout, _ = os.Open(os.DevNull)

	for _, tt := range templates {

		for _, vv := range values {
			options := &helm.Options{
				SetValues: map[string]string{
					"ingress.enabled":     "true",
					tt.ingressClassKey:    vv.ingressClassName,
					tt.deprecatedClassKey: vv.deprecatedClassName,
				},
			}

			output := helm.RenderTemplate(t, options, helmChartPath, "refinery", []string{tt.templateFile})

			var ingress networkingv1.Ingress
			helm.UnmarshalK8SYaml(t, output, &ingress)

			ingressClassName := *ingress.Spec.IngressClassName
			require.Equal(t, vv.expectedIngress, ingressClassName)
		}
	}
}
