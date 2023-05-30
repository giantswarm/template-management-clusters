

### Please check if PR meets these requirements

- [ ] Critical resources are protected from accidental deletion by the [Flux annotations](https://fluxcd.io/flux/components/kustomize/kustomization/#garbage-collection).
- [ ] Results of the diffs have been examined and no unintended changes are being introduced.

### Helper

* to disable the GH Action generating manifests diffs for installations, between target and source branches, comment the `/no_diffs_printing` on the PR.
* to disable the GH Action for configuration drift detection in the `flux` Flux Kustomization CRs, between target and source branches, comment the `/no_drift_detection` on the PR.
