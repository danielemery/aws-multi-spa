import { PropsWithChildren } from "react";
import { Link } from "react-router-dom";

type FlexLinkProps = PropsWithChildren<{ to: string }>;

export default function FlexLink({ to, children }: FlexLinkProps) {
  if (to.startsWith(import.meta.env.VITE_BASE_URL)) {
    return <Link to={to}>{children}</Link>;
  }

  return <a href={to}>{children}</a>;
}
