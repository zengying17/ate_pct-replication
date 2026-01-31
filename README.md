# ate_pct-replication

Replication files for the empirical analyses in the paper:

**“Estimation and Inference on Average Treatment Effect in Percentage Points under Heterogeneity.”**

This repository contains Stata do-files and supporting datasets used to reproduce the empirical results.

---

## Requirements

- **Stata** (Stata 14+ is recommended)
- The `ate_pct` Stata package (installation instructions below)

---

## Install `ate_pct`

Install the accompanying Stata command **before** running any replication do-files.

- **Option A (SSC):**
  ```stata
  ssc install ate_pct
````

* **Option B (latest version on GitHub):**
  [https://github.com/zengying17/ate_pct-stata](https://github.com/zengying17/ate_pct-stata)

---

## Files included

### Replication files for Atkin et al. (2017)

* `analysis.dta`
  Original dataset for Atkin et al. (2017), downloaded from the Harvard Dataverse:
  [https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/QOGMVI](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/QOGMVI)

* `rep_ATKK2017.do`
  Stata do-file that reproduces the results for the Atkin et al. (2017) application.

### Replication files for the watersheds application (Alsan and Goldin, 2019)

* `watersheds_dataset.dta`
  Dataset used in Alsan and Goldin (2019). Source:
  [https://www.journals.uchicago.edu/doi/abs/10.1086/700766](https://www.journals.uchicago.edu/doi/abs/10.1086/700766)

* `rep_AG2019.do`
  Stata do-file that reproduces the results for the Alsan and Goldin (2019) application.
