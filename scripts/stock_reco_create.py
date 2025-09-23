import os
import json
from datetime import datetime

import frappe


def main():
    company = os.environ.get("COMPANY", "Mr Mads")
    warehouse = os.environ.get("WAREHOUSE", "Toko - MM")
    qty = int(os.environ.get("QTY", "100"))

    # Get all stock items (enabled, not variant of disabled)
    items = frappe.get_all(
        "Item",
        filters={"disabled": 0, "is_stock_item": 1},
        fields=["name"],
        limit=None,
    )

    if not items:
        print("No stock items found")
        return

    doc = frappe.new_doc("Stock Reconciliation")
    doc.company = company
    doc.purpose = "Stock Reconciliation"
    doc.posting_date = datetime.now().date()
    doc.posting_time = datetime.now().time().strftime("%H:%M:%S")
    doc.set_warehouse = warehouse

    for it in items:
        child = doc.append("items", {})
        child.item_code = it["name"]
        child.warehouse = warehouse
        child.qty = qty

    doc.insert(ignore_permissions=True)
    # Do not submit automatically; let user review and submit via UI
    print(json.dumps({
        "name": doc.name,
        "items": len(items),
        "company": company,
        "warehouse": warehouse,
        "qty": qty,
        "status": doc.docstatus,
    }))


if __name__ == "__main__":
    main()

