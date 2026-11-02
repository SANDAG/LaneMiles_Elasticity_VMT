# Development Roadmap

## 1. Project Objective

This repository prepares county-level transportation and socioeconomic datasets for statistical estimation of the relationship between roadway lane miles, VMT, and other explanatory variables.

The repository is being reorganized from a collection of R scripts and R Markdown workbooks into a modular, reproducible data-processing workflow.

**Development principles:**

- Process each dataset independently before combining datasets.
- Use shared configuration files for input/output directories; avoid hardcoded local paths and `setwd()`.
- Preserve existing analytical methods during the initial migration. Document and review methodological changes separately.
- Include data validation checks in every processing notebook.
- Keep original source data and generated outputs outside Git.
- Make small, logical commits and use pull requests for review.
- Document input sources, transformations, output schemas, and outstanding assumptions.

## 2. Repository Structure

Current and planned structure:

```text
LaneMiles_Elasticity_VMT/
├── archive/                    # Original scripts and notebooks
├── notebooks/
│   ├── 01_ipums_county.Rmd     # Initial implementation complete
│   ├── 02_hpms_county.Rmd      # Planned
│   ├── 03_urban_crosswalk.Rmd  # Planned
│   ├── 04_caltrans_prd.Rmd     # Planned
│   ├── 05_regression_data.Rmd  # Planned
│   └── 06_final_dataset.Rmd   # Planned
├── R/
│   └── load_config.R
├── config/
│   ├── default.yml
│   └── local.yml               # Local only; excluded from Git
├── docs/                       # Planned: data dictionary and methods
├── tests/                      # Planned: automated validation
├── data/
│   ├── raw/                    # Excluded from Git
│   └── processed/              # Excluded from Git
├── .gitignore
├── LaneMiles_Elasticity_VMT.Rproj
└── README.md
```

Notebooks should document each analytical stage. As processing becomes more complex, reusable functions should be moved into `R/` so they can be tested independently.

## 3. Development Status and Next Steps

### Phase 1 — IPUMS County Socioeconomic Data

**Status: Initial implementation complete; additional validation pending.**

Notebook: `notebooks/01_ipums_county.Rmd`

Output: `st_ipums_ct.csv`

Completed:
- [x] Load IPUMS metadata and microdata.
- [x] Filter selected western states.
- [x] Construct socioeconomic indicators.
- [x] Aggregate to county/year.
- [x] Add basic data-quality checks.
- [x] Export CSV and verify successful read-back.

Remaining:
- [ ] Compare outputs against the legacy workflow.
- [ ] Review unidentified counties and missing values.
- [ ] Review IPUMS person/household weighting assumptions.
- [ ] Document variable definitions, temporal coverage, and known limitations.

The new notebook has been executed successfully, but equivalence with historical outputs and methodological validity have not yet been established.

### Phase 2 — FHWA HPMS Roadway Data

**Status: Not started. Highest-priority new development task.**

Source: Section 3 of `archive/LaneMiles_Workbook.Rmd`

Planned notebook: `notebooks/02_hpms_county.Rmd`

Expected output: `hpms_st_8323_ct.csv`

Tasks:
- [ ] Inventory required HPMS input files for 1983, 1993, 2003, 2013, and 2023.
- [ ] Move file paths and input filenames into configuration.
- [ ] Separate year-specific loading and cleaning logic where source formats differ.
- [ ] Standardize field names, FIPS identifiers, units, and functional classifications across years.
- [ ] Calculate VMT, roadway miles, and lane miles.
- [ ] Aggregate to county/year/roadway category (IH and MRU).
- [ ] Incorporate and document the historical railroad data dependency.
- [ ] Add checks for missing counties, duplicate keys, invalid values, and unexpected changes in totals.
- [ ] Compare output with the existing HPMS county dataset.

**Special attention:** The historical HPMS files and 2023 geodatabase tables have different structures. Field mappings and historical functional-class definitions should be documented explicitly.

### Phase 3 — Urban Area to County Crosswalk

**Status: Legacy implementation commented out; requires review and testing.**

Source: Section 4 of the original workbook.

Planned notebook: `notebooks/03_urban_crosswalk.Rmd`

Expected output: `counties_dvmt_pop_0323.csv`

Tasks:
- [ ] Review the original crosswalk methodology.
- [ ] Inventory Missouri Census Data Center (Geocorr) inputs.
- [ ] Establish appropriate population or land-area weights for each year.
- [ ] Allocate urban-area roadway metrics to counties.
- [ ] Check crosswalk completeness and allocation-weight sums.
- [ ] Verify that allocated totals reconcile with source totals.
- [ ] Document assumptions about changing urban-area boundaries.

Do not simply uncomment the historical code. It should be reviewed and tested as a separate processing stage.

### Phase 4 — Caltrans Public Road Data (PRD)

**Status: Legacy implementation commented out; requires review and testing.**

Source: Section 5 of the original workbook.

Planned notebook: `notebooks/04_caltrans_prd.Rmd`

Expected output: `counties_dvmt_pop_0323_ct.csv`

Tasks:
- [ ] Review Caltrans PRD inputs and their coverage.
- [ ] Use the county crosswalk developed in Phase 3.
- [ ] Process roadway miles, lane miles, and VMT by functional classification.
- [ ] Reconcile FHWA and Caltrans roadway categories.
- [ ] Validate annual and county-level totals.
- [ ] Document known differences between FHWA HPMS and Caltrans PRD.

### Phase 5 — Regression Dataset Assembly

**Status: Legacy code exists; migration pending.**

Source: Section 6 of the original workbook.

Planned notebook: `notebooks/05_regression_data.Rmd`

Expected output: `hpms_ipums_8323_2026.csv`

Tasks:
- [ ] Read independently validated FHWA and PRD outputs.
- [ ] Standardize county FIPS, years, and roadway categories.
- [ ] Convert roadway data into the required long/panel format.
- [ ] Join FHWA and PRD measurements.
- [ ] Resolve existing code inconsistencies and undefined object references.
- [ ] Validate join cardinality and check for duplicated records.
- [ ] Confirm completeness by county, year, and roadway category.
- [ ] Export the intermediate regression dataset.

### Phase 6 — Final Socioeconomic and DMV Data Integration

**Status: Legacy code exists; migration pending.**

Source: Section 7 of the original workbook.

Planned notebook: `notebooks/06_final_dataset.Rmd`

Expected output: `hpms_ipums_counties_8323_2026.csv`

Tasks:
- [ ] Inventory required Census, ACS, IPUMS, and California DMV datasets.
- [ ] Identify which supporting datasets are generated by other scripts in `archive/`.
- [ ] Standardize geographic and temporal identifiers.
- [ ] Document how socioeconomic years align with roadway data years.
- [ ] Join all socioeconomic and roadway variables.
- [ ] Confirm that joins do not unexpectedly multiply observations.
- [ ] Evaluate missing values, coverage, and variable definitions.
- [ ] Validate the final output and prepare a data dictionary.

**Important dependency:** The legacy final assembly references `ca_ipums_ct.csv` and two ACS output files, which are not produced by the new IPUMS notebook. These dependencies and the relationship to `st_ipums_ct.csv` must be resolved before final integration.

## 4. Standard Workflow for Each Processing Stage

Each new notebook should follow the same organization:

1. **Setup:** Load required libraries and shared configuration.
2. **Load inputs:** Verify files exist and required fields are present.
3. **Process data:** Apply clearly documented cleaning and transformation steps.
4. **Aggregate or join:** Define the expected observation unit and unique keys.
5. **Validate:** Check coverage, duplicates, missing values, ranges, and totals.
6. **Export:** Save the processed dataset to the configured output directory.
7. **Verify output:** Reopen the output and confirm its schema and record count.
8. **Document:** Record methodology, known issues, and validation status.

Avoid clearing the entire R environment or depending on objects created by previous notebooks. Each notebook should be runnable independently using its configured inputs.

## 5. Definition of Done

A processing stage is ready for review when:

- [ ] It runs successfully from a fresh R session with the required inputs available.
- [ ] No developer-specific file paths or credentials are hardcoded.
- [ ] Its input files and required packages are documented.
- [ ] The output file, fields, units, and unique keys are documented.
- [ ] Validation checks have been executed and reviewed.
- [ ] Historical-output comparison is completed where possible, or the reason it is pending is documented.
- [ ] Known methodological issues are identified.
- [ ] Generated datasets and local settings are excluded from Git.
- [ ] Changes are committed on a feature branch and submitted through a pull request.

A successful execution alone does not establish that a dataset is analytically validated.

## 6. Git and Code Review Practices

Use one feature branch per processing stage or focused improvement.

Examples:
- `feat/hpms-county-prep`
- `feat/urban-county-crosswalk`
- `feat/caltrans-prd`
- `fix/ipums-weighting`
- `docs/data-dictionary`

Recommended workflow:

1. Create a GitHub issue describing the task and acceptance criteria.
2. Create a feature branch.
3. Implement and locally test the changes.
4. Commit logical units of work with descriptive messages.
5. Open a pull request to the appropriate integration branch.
6. Include a summary of input data, output data, validation results, and outstanding issues.
7. Merge after review.

Example commit messages:
- `feat: add HPMS 2023 data loading`
- `feat: harmonize historical HPMS fields`
- `test: add county-year uniqueness checks`
- `fix: correct FHWA and PRD join keys`
- `docs: document HPMS source data assumptions`

Once the initial repository reorganization is merged, new feature branches should normally be created from `main`.

## 7. Reproducibility and Repository Maintenance

Additional improvements to implement as the pipeline matures:

- [ ] Create an input/output data inventory in `docs/`.
- [ ] Introduce `renv` to record tested R package versions.
- [ ] Create reusable functions for common operations and validation.
- [ ] Add automated tests for stable data contracts and small representative fixtures.
- [ ] Document the sequence and dependencies of processing stages.
- [ ] Establish a consistent convention for file names and output schemas.
- [ ] Review archived scripts for hardcoded credentials; revoke or replace exposed keys and ensure secrets are not included in new code.
- [ ] Remove or consolidate obsolete code only after the replacement has been validated.
- [ ] Document the process for rebuilding the complete estimation dataset.

## 8. Immediate Staff Priorities

The next developer should focus on the following, in order:

1. Review the working IPUMS notebook and complete its outstanding validation.
2. Inventory the HPMS files, source formats, and transformations.
3. Implement and validate the HPMS processing notebook in small, reviewable increments.
4. Document any issues that require methodological decisions before changing the underlying calculations.
5. Continue with the urban-area crosswalk and PRD processing once HPMS is stable.

The initial goal is a reproducible and reviewable data-preparation pipeline, not a redesign of the statistical estimation methodology.