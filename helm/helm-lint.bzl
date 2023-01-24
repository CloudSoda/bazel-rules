load("//helpers:helpers.bzl", "write_sh")

def _helm_lint_test_impl(ctx):
    """Lint a helm chart"""

    chart = ctx.file.chart
    chart_path = ctx.file.chart.short_path
    package_name = ctx.attr.package_name

    # Generates the exec bash file with the provided substitutions
    exec_file = write_sh(
      ctx,
      "helm_lint_test",
      """
        tar --touch -xf {CHART_PATH}
        helm lint {PACKAGE_NAME}
      """,
      {
        "{CHART_PATH}": chart_path,
        "{PACKAGE_NAME}": package_name,
      }
    )

    runfiles = ctx.runfiles(files = [chart])

    return [DefaultInfo(
      executable = exec_file,
      runfiles = runfiles,
    )]

helm_lint_test = rule(
    implementation = _helm_lint_test_impl,
    attrs = {
      "chart": attr.label(allow_single_file = True, mandatory = True),
      "package_name": attr.string(mandatory = True),
    },
    doc = "Lint helm chart",
    test = True,
    toolchains = [
      "@com_github_masmovil_bazel_rules//toolchains/helm-3:toolchain_type",
    ],
)
