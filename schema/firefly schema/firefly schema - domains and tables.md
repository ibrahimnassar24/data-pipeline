I extracted the table names from the ERD. There are **83 tables** in total.

## Users & Authentication

1. users
2. user_groups
3. user_roles
4. group_memberships
5. 2fa_tokens
6. invited_users
7. sessions
8. preferences
9. roles
10. permissions
11. role_user
12. permission_role

## Accounts

13. accounts
14. account_types
15. account_meta
16. account_balances

## Transactions

17. transactions
18. transaction_journals
19. transaction_groups
20. transaction_types
21. transaction_currencies
22. journal_meta
23. group_journals
24. journal_links
25. link_types
26. transaction_currency_user
27. transaction_currency_user_group
28. currency_exchange_rates

## Budgets

29. budgets
30. budget_limits
31. available_budgets
32. auto_budgets
33. budget_transaction
34. budget_transaction_journal
35. limit_repetitions

## Categories & Tags

36. categories
37. category_transaction_journal
38. category_transaction
39. tags
40. tag_transaction_journal

## Bills & Recurrences

41. bills
42. recurrences
43. recurrences_transactions
44. recurrences_repetitions
45. recurrences_meta
46. rt_meta

## Piggy Banks

47. piggy_banks
48. piggy_bank_events
49. piggy_bank_repetitions
50. account_piggy_bank

## Rules

51. rule_groups
52. rules
53. rule_actions
54. rule_triggers

## Objects & Attachments

55. object_groups
56. object_groupables
57. attachments
58. notes
59. locations

## Webhooks

60. webhooks
61. webhook_messages
62. webhook_attempts
63. webhook_deliveries
64. webhook_webhook_delivery
65. webhook_responses
66. webhook_triggers
67. webhook_webhook_trigger
68. webhook_webhook_response

## OAuth & Security

69. oauth_clients
70. oauth_access_tokens
71. oauth_auth_codes
72. oauth_refresh_tokens
73. oauth_device_codes
74. personal_access_tokens
75. audit_log_entries

## Statistics & System

76. period_statistics
77. configuration
78. migrations
79. jobs
80. failed_jobs
81. password_resets
82. notifications
83. meta_names

### Observations

Several tables are **junction (many-to-many) tables**, identifiable by names such as:

* role_user
* permission_role
* group_memberships
* budget_transaction
* budget_transaction_journal
* category_transaction
* category_transaction_journal
* tag_transaction_journal
* account_piggy_bank
* group_journals
* object_groupables
* webhook_webhook_delivery
* webhook_webhook_trigger
* webhook_webhook_response

These tables are primarily used to connect two entities together.

The most important business tables appear to be:

* users
* accounts
* transaction_groups
* transaction_journals
* transactions
* budgets
* categories
* tags
* bills
* recurrences
* piggy_banks
* rules

These form the core of the application's financial domain.

A useful next step would be to classify all 83 tables into:

* **Aggregate roots**
* **Child entities**
* **Lookup/reference tables**
* **Junction tables**
* **Infrastructure/system tables**

That classification makes the ERD much easier to understand before analyzing relationships.
