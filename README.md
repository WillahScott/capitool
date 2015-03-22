# CapiTool

**Regulatory Capital Simulation for different stress scenarios, mainly for educational purposes**

This tool permits an educational exploration of how intuitively different macro-variables affect the regulatory capital requirements set by the Capital Requirements as set by the European Parliament in the CRD IV.


### Regulation
The Capital Requirements Directive (CRD IV) establishes the amount of capital a bank must have allocated, given as a different functions of the estimated probability of default (for performing products), severity and exposure, for each different product.

The Stress Test exercise regulation put forth by the EBA requires a 3 year projection (or US Stress Test, CCAR establishes 9 quarters projection) of regulatory capital. *CapiTool* allows up to 3 year projection.

The (European) Stress Test exercise requires two scenarios set forth by the EBA, as well as any scenarios required by the national regulators. For the US CCAR exercise, 3 exercises are necessary, as well as two internal scenarios which the institution has to create.


### Estimation for different scenarios
*CapiTool* allows for a user to set the economic tone of the coming 3 years by beeing able to set 5 key macro-variables to *Green* (Base), *Amber* (Adverse), *Red* (Severely Adverse) or *Danger!* (Extreme Recession). The macrovariables able to tweak are:
 - **Gross Domestic Product (GDP)** [def](http://en.wikipedia.org/wiki/Gross_domestic_product)  
 - **Unemployment Rate** [def](http://en.wikipedia.org/wiki/Unemployment#United_States_Bureau_of_Labor_statistics)  
 - **Consumer Price Index** [def](http://en.wikipedia.org/wiki/Consumer_price_index)  
 - **House Price Index** [def](http://en.wikipedia.org/wiki/House_price_index)  
 - **Treasury 10-year Note** [def](http://en.wikipedia.org/wiki/United_States_Treasury_security#Treasury_note)  


### Projection
The scenarios affect different products with different sensitivities. These sensitivities have been calculated in a simple manner, keeping with the most basic business sense. The scenarios affect directly the PD (probability of default) and the LGD (severity)for each loan.

### Regulatory Capital Calculation
The PDs, LGDs and EADs (exposure), as well as the Impairment already allocated for each loan determine the Expected Loss best estimate and the Risk Weight (following the Capital Requirements Curve of the CRD IV). The Risk Weights are transformed into Risk Weighted Assets and the 8% of the sum of all RWA is what the CRD determines as the Regulatory Capital.

Note that the capital requirements are different for Performing assets than those for Defaulted assets (as determined by the regulation).


### *CapiTool* inputs
 - **Macroeconomic Scenario** - the expected behaviour for the different macrovariables as explained above.
 - **Projection Window** - years to project (*Default* all: from 2015 up to 2017).
 - **Product Breakdown** - Checkbox, if selected a projected capital by product breakdown will be plotted.
 - **Products** - when *product breakdown* is selected, the products to see in detail can be filtered *[Note: the total capital projection will be unaffected]*


### *CapiTool* usage
After setting the inputs, user must press *Simulate!* button to action the re-estimation and re-calculation of the projected capital.


### *CapiTool* output
The tool provides the projected regulatory capital for the projection window selected.

When selected, a product breakdown of the capital can be seen on the right side of the main panel.


##### By WillahScott - WiDo Stuff