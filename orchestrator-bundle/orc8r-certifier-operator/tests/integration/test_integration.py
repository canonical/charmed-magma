#!/usr/bin/env python3
# Copyright 2021 Canonical Ltd.
# See LICENSE file for licensing details.

import logging
from pathlib import Path

import pytest
import yaml
from pytest_operator.plugin import OpsTest  # type: ignore[import]  # noqa: F401

logger = logging.getLogger(__name__)
METADATA = yaml.safe_load(Path("./metadata.yaml").read_text())

APPLICATION_NAME = "orc8r-certifier"
CHARM_NAME = "magma-orc8r-certifier"


class TestOrc8rCertifier:
    @pytest.fixture(scope="module")
    @pytest.mark.abort_on_fail
    async def setup(self, ops_test):
        await ops_test.model.deploy("postgresql-k8s", application_name="postgresql-k8s")
        await ops_test.model.wait_for_idle(apps=["postgresql-k8s"], status="active", timeout=1000)
        await self._deploy_tls_certificates_operator(ops_test)

    @staticmethod
    async def _deploy_tls_certificates_operator(ops_test):
        await ops_test.model.deploy(
            "tls-certificates-operator",
            application_name="tls-certificates-operator",
            config={"generate-self-signed-certificates": True},
            channel="edge",
        )

    @pytest.fixture(scope="module")
    @pytest.mark.abort_on_fail
    async def build_and_deploy(self, ops_test, setup):
        charm = await ops_test.build_charm(".")
        resources = {
            f"{CHARM_NAME}-image": METADATA["resources"][f"{CHARM_NAME}-image"]["upstream-source"],
        }
        await ops_test.model.deploy(
            charm,
            resources=resources,
            application_name=APPLICATION_NAME,
            config={"domain": "example.com"},
            trust=True,
        )

    @pytest.mark.abort_on_fail
    async def test_wait_for_blocked_status(self, ops_test, setup, build_and_deploy):
        await ops_test.model.wait_for_idle(apps=[APPLICATION_NAME], status="blocked", timeout=1000)

    async def test_build_and_deploy(self, ops_test, setup, build_and_deploy):
        await ops_test.model.add_relation(
            relation1=APPLICATION_NAME, relation2="postgresql-k8s:db"
        )
        await ops_test.model.add_relation(
            relation1=APPLICATION_NAME, relation2="tls-certificates-operator"
        )
        await ops_test.model.wait_for_idle(apps=[APPLICATION_NAME], status="active", timeout=1000)
