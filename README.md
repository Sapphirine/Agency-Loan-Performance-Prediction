## Synopsis
This project contains a few classification and regression algorithmns that are used to predict Freddie Mac's Single family loan default performance. The main algorithmns include: Logistic regression, Gradient Boosting, Random Forest, GLMNET regression, neural network, etc.

## Data Labels
'integrated_data.csv' are the final version of the data with no NULL values inside.

It has around 2.5 million loans originated from Q42009 to Q42011.

Most of the columns are slightly modified (delete NA rows) and using their original column names in freddie-mac's data. Some are derived or modified by me, and below is the explanation.

FIRST_TIME_HOME_BUYER_FLAG: The empty entries is replaced by 'U', which means unknown

MSA: If the MSA code could be found in our HPI file, then it would remain the same. Otherwise, it is replaced by the property state.

MORTGAGE_INSURANCE_PCT: The data type for this column is modified from string to float.

LOAN_SIZE: The ORIGINAL UPB column in the freddie mac's origination data.

SUPER_CONFORMING_FLAG: Replace empty entries to 'N'

LOAN_ID: The original LOAN SEQUENCE NUMBER column, only loans which have records in the time data, and whose property state can be found in HPI data are picked.

HPI_MAX/MIN: The loan's highest/lowest HPI in the first 60 months

HPI_ORIG: The loan's HPI at origination month

IND_DEFAULT_1: Equal to one when the loan ever reached D150 states or its zero balance code was ever equal to 03 or 09.

IND_DEFAULT_2: Equal to one when the loan ever reached D150 states or its zero balance code was ever equal to 03 or 06 or 09.

## Contributors
Guanjie Huang, Zhening Liu and Jiada Chen
