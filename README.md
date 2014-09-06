# Watcard

A command line tool for accessing your watcard history and balance.

## Installation

Install the gem with:

    $ gem install watcard

Create the config file `~/.watcard.yml`:

```yaml
---
# Student id and watcard pin
id: 12345678
pin: 1234
# Daily food budget to use for reference (in dollars)
budget: 19
# Ledger output file
ledger: ~/Box/Life/watcard.ldg
# Accounts to use in Ledger output for different watcard balances
accounts:
  # Meal Plan are account 1
  1: ["Expenses:Food:Meals","Assets:WatCard:Meal Plan"]
  # Flex Dollars are account 4
  4: ["Expenses:Misc University","Assets:WatCard:Flex"]
```

*Note: you can find the web UI for setting your pin and online access [here](https://account.watcard.uwaterloo.ca/).*

## Usage

### History

Fetches history for a day and compares it with the budget (if there is one).

    $ watcard hist
    # Fetching history for 2014-09-05 19:53:54 -0400
    Breakfast: $3.14 @ V1 Cafeteria
    Dinner: $5.78 @ V1 Cafeteria
    = $8.92 out of $19 surplus: 10.08
    $ watcard hist 1 # One day ago
    # Fetching history for 2014-09-04 19:53:01 -0400
    Breakfast: $6.24 @ V1 Cafeteria
    Lunch: $7.70 @ Liquid Assets
    Dinner: $6.28 @ V1 Cafeteria
    = $20.22 out of $19 surplus: -1.22

### Ledger

Outputs double entry transactions in [ledger](http://ledger-cli.org/) format and optionally appends them to a file.

    $ watcard ledger 1
    # Fetching history for 2014-09-04 20:06:31 -0400
    # Transactions:

    2014/09/04 Breakfast at V1 Cafeteria
      Expenses:Food:Meals  $6.24
      Assets:WatCard:Meal Plan

    2014/09/04 Lunch at Liquid Assets
      Expenses:Food:Meals  $7.70
      Assets:WatCard:Meal Plan

    2014/09/04 Dinner at V1 Cafeteria
      Expenses:Food:Meals  $6.28
      Assets:WatCard:Meal Plan
    # Add to file [yN]: n

You can use this with `ledger`'s budgeting and accounting features to do lots of cool things like determine your current watcard balance and see budgeting stuff.

    $ ledger -f watcard.ldg --period 'this week' --budget register expenses
    14-Sep-01 Budget transaction    Expenses:Food:Meals         $-19.00      $-19.00
    14-Sep-01 Lunch at V1 Cafeteria Expenses:Food:Meals           $7.74      $-11.26
    14-Sep-02 Budget transaction    Expenses:Food:Meals         $-19.00      $-30.26
    14-Sep-02 Breakfast at V1 Caf.. Expenses:Food:Meals           $1.34      $-28.92
    14-Sep-03 Budget transaction    Expenses:Food:Meals         $-19.00      $-47.92
    14-Sep-03 Breakfast at V1 Caf.. Expenses:Food:Meals           $5.40      $-42.52
    14-Sep-04 Budget transaction    Expenses:Food:Meals         $-19.00      $-61.52
    14-Sep-04 Breakfast at V1 Caf.. Expenses:Food:Meals           $6.24      $-55.28
    14-Sep-04 Lunch at Liquid Ass.. Expenses:Food:Meals           $7.70      $-47.58
    14-Sep-04 Dinner at V1 Cafete.. Expenses:Food:Meals           $6.28      $-41.30
    14-Sep-05 Budget transaction    Expenses:Food:Meals         $-19.00      $-60.30
    14-Sep-05 Breakfast at V1 Caf.. Expenses:Food:Meals           $3.14      $-57.16
    14-Sep-05 Dinner at V1 Cafete.. Expenses:Food:Meals           $5.78      $-51.38
    $ ledger -f watcard.ldg balance
                $2197.88  Assets:WatCard
                 $191.50    Flex
                $2006.38    Meal Plan
               $-2250.00  Equity:RESP
                  $52.12  Expenses
                  $43.62    Food:Meals
                   $8.50    Misc University
    --------------------
                       0
