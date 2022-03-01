#!/usr/bin/env python3
# Copyright 2022 Ubuntu
# See LICENSE file for licensing details.
#
# Learn more at: https://juju.is/docs/sdk

"""Charm the service.

Refer to the following post for a quick-start guide that will help you
develop a new k8s charm using the Operator Framework:

    https://discourse.charmhub.io/t/4208
"""

import logging

import ops.lib
from ops.charm import CharmBase
from ops.framework import Object
from ops.model import ActiveStatus, BlockedStatus, MaintenanceStatus, WaitingStatus
from ops.pebble import Layer
from pgconnstr import ConnectionString  # type: ignore[import]

logger = logging.getLogger(__name__)
pgsql = ops.lib.use("pgsql", 1, "postgresql-charmers@lists.launchpad.net")


class DatabaseIntegratorOperatorCharm(CharmBase):
    DB_NAME = "magma_dev"

    def __init__(self, *args):
        super().__init__(*args)
        self.framework.observe(self.on["magma-db"].relation_changed, self._on_relation_joined)
        
        self._db = pgsql.PostgreSQLClient(self.charm, "db")
        self.framework.observe(
            self._db.on.database_relation_joined, self._on_database_relation_joined
        )
        
    def _on_relation_joined(self, event):
        if not self._db_relation_established():
            self.charm.unit.status = BlockedStatus(
                "Waiting for database relation to be established..."
            )
            event.defer()
            return
        self._send_relation_data()
    
    def _send_relation_data(self, event):
        to_publish = [event.relation.data[self.unit]]
        for bucket in to_publish:
            bucket["db_connection_string"] = self._db_connection_string
        
        return to_publish
        
    def _on_database_relation_joined(self, event):
        """
        Event handler for database relation change.
        - Sets the event.database field on the database joined event.
        - Required because setting the database name is only possible
          from inside the event handler per https://github.com/canonical/ops-lib-pgsql/issues/2
        - Sets our database parameters based on what was provided
          in the relation event.
        """
        db_connection_string = event.master
        if self.charm.unit.is_leader() and db_connection_string is not None:
            event.database = self.DB_NAME
        elif event.database != self.DB_NAME or db_connection_string is None:
            event.defer()
            return
        
    
    def _db_relation_established(self):
        """Validates that database relation is ready (that there is a relation and that credentials
        have been passed)."""
        if not self._db_connection_string:
            self.charm.unit.status = WaitingStatus("Waiting for db relation to be ready...")
            return False
        return True
    
    @property
    def _db_connection_string(self):
        """Returns DB connection string provided by the DB relation."""
        try:
            db_relation = self.model.get_relation("db")
            return ConnectionString(db_relation.data[db_relation.app]["master"])
        except (AttributeError, KeyError):
            return None

if __name__ == "__main__":
    main(DatabaseIntegratorOperatorCharm)
